Subject: Unable to boot 2.6.0-test1-mm2 (mm1 is OK) on RH 9.0.93 (Severn)
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Message-Id: <1058887517.1668.16.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Date: 22 Jul 2003 09:25:18 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I get this error when trying to boot 2.6.0-test1-mm2 using the new Red
Hat beta (Severn).  2.6.0-test2-mm2 runs successfully on a couple of
other test boxes of mine.

VFS: Cannot open root device "hda1" or unknown-block(0,0)
Please append a correct "root=" boot option
Kernel panic: VFS: Unable to mount root fs on unknown-block(0,0)

Linux-2.6.0-test1-mm2 had this additional akpm patch applied:
http://marc.theaimsgroup.com/?l=linux-mm&m=105868155010855&w=2

Here is my /etc/lilo.conf.  All the other kernels boot and run fine.
I removed the devlabel stuff from virgin Severn (fstab and rc.sysinit).

prompt
timeout=50
default=linux
boot=/dev/hda
map=/boot/map
install=/boot/boot.b
message=/boot/message
linear

image=/boot/vmlinuz-2.4.21-20.1.2024.2.1.nptl
        label=linux
        initrd=/boot/initrd-2.4.21-20.1.2024.2.1.nptl.img
        read-only
        append="hdc=ide-scsi root=/dev/hda1"

image=/boot/vmlinuz-2.4.22-pre6
        label=2.4-22-pre6
        read-only
        append="devfs=nomount hdc=ide-scsi root=/dev/hda1"

image=/boot/vmlinuz-2.6.0-test1-mm1
        label=2.6.0-test1mm1
        read-only
        append="devfs=nomount hdc=ide-scsi root=/dev/hda1"

image=/boot/vmlinuz-2.6.0-test1-mm2
        label=2.6.0-test1mm2
        read-only
        append="devfs=nomount hdc=ide-scsi root=/dev/hda1"

image=/boot/vmlinuz-2.6-bk
        label=2.6-bk
        read-only
        append="devfs=nomount hdc=ide-scsi root=/dev/hda1"

The .config for -mm2 is the same as for -mm1, just run through 
make oldconfig. That -mm1 .config came from the working 2.6-bk .config,
also run through make oldconfig too.

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
