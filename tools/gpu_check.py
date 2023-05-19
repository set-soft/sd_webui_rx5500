import colorama as co
import grp
import os
import os.path as op
import re
import subprocess as sp
DRI = '/dev/dri'
INS_AMDGPU = """Install the amdgpu kernel module. Consult: https://www.amd.com/en/support/kb/faq/amdgpu-installation
You could download the amdgpu-install tool and run:

amdgpu-install --usecase=dkms

Using --usecase=rocm isn't recommended"""
hd_pat = r'[0-9a-zA-Z]'
dev_pat = f'{hd_pat}{{4}}:{hd_pat}{{2}}:{hd_pat}{{2}}\.{hd_pat}'
card_re = re.compile(f'({dev_pat}) VGA compatible controller (.*)\[AMD\/ATI] (.*) \[({hd_pat}{{4}}:{hd_pat}{{4}})\](?: \(rev ({hd_pat}{{2}})\))?')
#0000:0a:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Navi 14 [Radeon RX 5500/5500M / Pro 5500M] [1002:7340] (rev c5)
#	Subsystem: ASUSTeK Computer Inc. Navi 14 [Radeon RX 5500/5500M / Pro 5500M] [1043:04e6]
#	Kernel driver in use: amdgpu
#	Kernel modules: amdgpu

def error(msg, action):
    print(co.Fore.RED+"Error: "+msg)
    print("Solution: "+action)
    exit(1)


def run_cmd(cmd, action):
    try:
        res = sp.run(cmd, check=True, stdout=sp.PIPE, stderr=sp.STDOUT)
    except sp.CalledProcessError as e:
        error(f"Error running {cmd[0]}", "Solve the described error\n"+str(e))
        exit(1)
    except FileNotFoundError:
        error(f"Failed to run {cmd[0]}", action)
        exit(1)
    return res.stdout.decode().rstrip()


def look_for_card():
    res = run_cmd(['lspci', '-Dk', '-nn'], "Install pciutils")
    dev = None
    collect = False
    card = None
    for l in res.split('\n'):
        match = card_re.search(l)
        #print(l)
        if match:
            #print(match.groups())
            dev = match.group(1)
            gpu = match.group(3)
            id = match.group(4)
            rev = match.group(5)
            print(f"- GPU: {gpu}")
            check_id(id)
            collect = True
            continue
        if l[0] != '\t' or not collect:
            collect = False
            continue
        # Collecting info
        if l.startswith('\tSubsystem: '):
            card = l[12:]
            print(f"- Video board: {card}")
        elif l.startswith('\tKernel driver in use: '):
            module = l[23:]
            print(f"- Kernel module: {module}")
    if dev is None:
        error('Failed to find a PCI AMD VGA card', 'Check the lspci output, report this problem')
    return dev, gpu, id, rev, card, module


def fail_msg(msg):
    print(msg+co.Fore.RED+' Fail'+co.Style.RESET_ALL)


def ok_msg(msg):
    print(msg+co.Fore.GREEN+' OK'+co.Style.RESET_ALL)


def msg_qualify(msg, ok):
    if ok:
        ok_msg(msg)
    else:
        fail_msg(msg)


def check_id(id):
    vendor, device = id.split(':')
    msg_qualify(f"  - GPU Vendor: {vendor}", vendor == '1002')
    print(f"  - GPU ID: {device}")


print("Checking for AMD GPUs ...")
print("DRM:")
if not op.isdir(DRI):
    error("No Direct Rendering Infrastructure (no accelerated graphics)", INS_AMDGPU)
print("- Direct Rendering Infrastructure found")
# List the PCI devices looking for an AMD VGA controller
dev, gpu, id, rev, card, module = look_for_card()

# Look for the /dev/dri/cardN device
card_dev = f'/dev/dri/by-path/pci-{dev}-card'
if not op.islink(card_dev):
    error(f'Failed to find card device for PCI device {dev} ({card_dev})',
          'Use lspci to check this is your video board.\n'+INS_AMDGPU)
card_dev = op.abspath(op.join(op.dirname(card_dev), os.readlink(card_dev)))
msg = f"- Card device: {card_dev}"
# Check this is owned by video group
stat_cd = os.stat(card_dev)
grp_cd = grp.getgrgid(stat_cd.st_gid)[0]
if grp_cd != 'video':
    fail_msg(msg)
    error('Card device not owned by the video group', 'Check users and groups in your system, report this problem')
# Check R/W
if not os.access(card_dev, os.R_OK | os.W_OK):
    fail_msg(msg)
    error("Current user can't use the video card", "Add the user to the video group")
ok_msg(msg)

# Look for the /dev/dri/render* device
render_dev = f'/dev/dri/by-path/pci-{dev}-render'
if not op.islink(render_dev):
    error(f'Failed to find render device for PCI device {dev} ({render_dev})',
          'Use lspci to check this is your video board.\n'+INS_AMDGPU)
render_dev = op.abspath(op.join(op.dirname(render_dev), os.readlink(render_dev)))
msg = f"- Render device: {render_dev}"
# Check this is owned by render group
stat_render = os.stat(render_dev)
grp_render = grp.getgrgid(stat_render.st_gid)[0]
if grp_render != 'render':
    fail_msg(msg)
    error('Card device not owned by the render group', 'Check users and groups in your system, report this problem')
# Check R/W
if not os.access(render_dev, os.R_OK | os.W_OK):
    fail_msg(msg)
    error("Current user can't use the GPU", "Add the user to the render group")
ok_msg(msg)

# Look for /dev/kfd
kfd_dev = '/dev/kfd'
msg = f"- Kernel Fusion Driver device: {kfd_dev}"
try:
    stat_kfd = os.stat(kfd_dev)
except FileNotFoundError:
    fail_msg(msg)
    error('Missing Kernel Fusion Driver device', 'Are you using a very old Radeon card?\n'+INS_AMDGPU)
grp_kfd = grp.getgrgid(stat_kfd.st_gid)[0]
if grp_kfd != 'render':
    fail_msg(msg)
    error('KFD device not owned by the render group', 'Check users and groups in your system, report this problem')
# Check R/W
if not os.access(kfd_dev, os.R_OK | os.W_OK):
    error("Current user can't use the KFD device", "Add the user to the render group")
ok_msg(msg)

