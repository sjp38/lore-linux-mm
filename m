Message-ID: <39B2FFC9.7913201B@sgi.com>
Date: Sun, 03 Sep 2000 18:50:01 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Boot problems with test8-pre1 + 2.4.0-t8p1-vmpatch2b
References: <8oudti$nrr6t$1@fido.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm having problems with booting test7 + test8-pre1 + 2.4.0-t8p1-vmpatch2b.
This is all the machine does on boot:

------------
LILO boot: 
Loading test8rr........
------------

Has anyone else seen problems like this? I have not tried
just test7 + test8-pre1, but test8-pre2 works ok. The
test machine is a 2P X86 64MB system.
Here's the .config [ modules and built-in's ]:

--------------
waco.engr.sgi.com>> egrep '=[my]' .config
CONFIG_X86=y
CONFIG_ISA=y
CONFIG_UID16=y
CONFIG_EXPERIMENTAL=y
CONFIG_MODULES=y
CONFIG_MODVERSIONS=y
CONFIG_KMOD=y
CONFIG_M686=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INVLPG=y
CONFIG_X86_CMPXCHG=y
CONFIG_X86_BSWAP=y
CONFIG_X86_POPAD_OK=y
CONFIG_X86_TSC=y
CONFIG_X86_GOOD_APIC=y
CONFIG_X86_PGE=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_NOHIGHMEM=y
CONFIG_SMP=y
CONFIG_HAVE_DEC_LOCK=y
CONFIG_NET=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_PCI=y
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_NAMES=y
CONFIG_SYSVIPC=y
CONFIG_SYSCTL=y
CONFIG_KCORE_ELF=y
CONFIG_BINFMT_AOUT=m
CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_MISC=m
CONFIG_BLK_DEV_FD=m
CONFIG_PACKET=m
CONFIG_UNIX=y
CONFIG_INET=y
CONFIG_SCSI=y
CONFIG_BLK_DEV_SD=y
CONFIG_SCSI_DEBUG_QUEUES=y
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_AHA152X=m
CONFIG_SCSI_AHA1740=m
CONFIG_SCSI_AIC7XXX=y
CONFIG_SCSI_NCR53C8XX=y
CONFIG_SCSI_SYM53C8XX=y
CONFIG_SCSI_QLOGIC_FC=m
CONFIG_NETDEVICES=y
CONFIG_DUMMY=m
CONFIG_NET_ETHERNET=y
CONFIG_NET_VENDOR_3COM=y
CONFIG_VORTEX=y
CONFIG_LANCE=y
CONFIG_NET_PCI=y
CONFIG_PCNET32=m
CONFIG_TULIP=m
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_SERIAL=y
CONFIG_SERIAL_CONSOLE=y
CONFIG_UNIX98_PTYS=y
CONFIG_MOUSE=y
CONFIG_PSMOUSE=y
CONFIG_82C710_MOUSE=y
CONFIG_DRM=m
CONFIG_DRM_TDFX=y
CONFIG_AUTOFS_FS=m
CONFIG_AUTOFS4_FS=m
CONFIG_ISO9660_FS=m
CONFIG_PROC_FS=y
CONFIG_DEVPTS_FS=y
CONFIG_EXT2_FS=y
CONFIG_NFS_FS=m
CONFIG_NFSD=m
CONFIG_SUNRPC=m
CONFIG_LOCKD=m
CONFIG_MSDOS_PARTITION=y
CONFIG_VGA_CONSOLE=y
-------------------


--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
