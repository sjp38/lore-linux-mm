Message-ID: <3E93EB0E.4030609@aitel.hist.no>
Date: Wed, 09 Apr 2003 11:42:38 +0200
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.5.67-mm1 cause framebuffer crash at bootup
References: <20030408042239.053e1d23.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, vandrove@vc.cvut.cz, jsimmons@infradead.org
List-ID: <linux-mm.kvack.org>

2.5.67 works with framebuffer console, 2.5.67-mm1 dies before activating
graphichs mode on two different machines:

smp with matroxfb, also using a patch that makes matroxfb work in 2.5
up with radeonfb, also using patches that fixes the broken devfs in mm1.

I use devfs and preempt in both cases, and monolithic kernels without module
support.

2.5.67-mm1 works if I drop framebuffer support completely.

Here is the printed backtrace for the radeon case, the matrox case was 
similiar:

<a few lines scrolled off screen>
pcibios_enable_device
pci_enable_device_bars
pci_enable_device
radeonfb_pci_register
sysfs_new_inode
pci_device_probe
bus_match
device_attach
bus_add_device
kobject_add
device_add
pci_bus_add_devices
pci_bus_add_devices
pci_scan_bus_parented
pcibios_scan_root
pci_legacy_init
do_initcalls
init_workqueues
init+0x36
init+0x00
kernel_thread_helper
code: Bad EIP value <0>Kernel panic:attempt to kill init!

sysrq worked and let me reboot.  No filesystems were
mounted at this point.

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
