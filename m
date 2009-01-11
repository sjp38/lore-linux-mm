Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D488D6B004F
	for <linux-mm@kvack.org>; Sun, 11 Jan 2009 13:45:07 -0500 (EST)
Date: Sun, 11 Jan 2009 18:36:00 +0000
From: Thorsten Kranzkowski <dl8bcu@dl8bcu.de>
Subject: Re: WARNING in vmap_page_range on alpha since 2.6.28
Message-ID: <20090111183600.GA2728@ds20.borg.net>
Reply-To: dl8bcu@dl8bcu.de
References: <20090111141855.GA7416@eric.schwarzvogel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090111141855.GA7416@eric.schwarzvogel.de>
Sender: owner-linux-mm@kvack.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, klausman@schwarzvogel.de
List-ID: <linux-mm.kvack.org>

On Sun, Jan 11, 2009 at 03:18:55PM +0100, Tobias Klausmann wrote:
> Hi! 
> 
> I've stumbled across this WARNING: when booting 2.6.28 + patch
> on my alpha. This happens consistently (i.e. on every boot) and
> keeps happening while the machine is booted:
> 
> ------------[ cut here ]------------
> WARNING: at mm/vmalloc.c:104 vmap_page_range+0x1b8/0x320()
> Modules linked in:
> fffffc007f03b968 0000000000000003 fffffc0000377e48 fffffffc00002000 
>        fffffffc00008000 0000000000000003 6761705f70616d76 2b65676e61725f65 
>        78302f3862317830 0000000000303233 fffffc00006f0828 0000000000000000 
>        fffffc00006efcd8 fffffc00006efcd8 fffffc00006f0830 0000000000000000 
>        0000000000000000 fffffc00006efd18 0000000000000001 00000000000200d2 
>        0000000000000000 0000000000000000 0000000000000001 0000000000000044 
> Trace:
> [<fffffc0000377e48>] vmap_page_range+0x1b8/0x320
> [<fffffc0000379288>] __vmalloc_area_node+0xb8/0x1b0
> [<fffffc0000377fe4>] map_vm_area+0x34/0x60
> [<fffffc0000379320>] __vmalloc_area_node+0x150/0x1b0
> [<fffffc00003792cc>] __vmalloc_area_node+0xfc/0x1b0
> [<fffffc00004da5d4>] agp_add_bridge+0x1a4/0x610
> [<fffffc00005d2858>] agp_amdk7_probe+0x17c/0x2ec
> [<fffffc000049627c>] pci_device_probe+0x8c/0xc0
> [<fffffc00004ff1b8>] driver_probe_device+0xa8/0x230
> [<fffffc00004ff41c>] __driver_attach+0xdc/0xe0
> [<fffffc00004fe698>] bus_for_each_dev+0x78/0xd0
> [<fffffc00004ff340>] __driver_attach+0x0/0xe0
> [<fffffc00004fef5c>] driver_attach+0x2c/0x40
> [<fffffc00004fdccc>] bus_add_driver+0x28c/0x340
> [<fffffc00004ff6e4>] driver_register+0x94/0x1d0
> [<fffffc00004965e4>] __pci_register_driver+0x64/0xf0
> [<fffffc0000310084>] do_one_initcall+0x34/0x1e0
> [<fffffc00003db60c>] proc_register+0x6c/0x280
> [<fffffc00003db5f0>] proc_register+0x50/0x280
> [<fffffc00003db9bc>] create_proc_entry+0x7c/0x100
> [<fffffc000035597c>] register_irq_proc+0xbc/0xe0
> [<fffffc0000355a14>] init_irq_proc+0x74/0xa0
> [<fffffc0000311158>] kernel_thread+0x28/0x90
> [<fffffc0000310d84>] entSys+0xa4/0xc0
> 
> ---[ end trace 9863e03dd539368c ]---


I see similar traces:

------------[ cut here ]------------
WARNING: at /export/data/scm/linux-2.6/mm/vmalloc.c:104 vmap_page_range+0x1c4/0x264()
Modules linked in:
fffffc007e303ae8 0000000000000000 fffffc00003823e0 fffffffc00188000 
       fffffc0000aee000 fffffc0000a57ac0 6761705f70616d76 2b65676e61725f65 
       78302f3463317830 0000000000343632 fffffc0000a58fc8 00000000000200d2 
       0000000000000000 0000000000000000 0000000000000001 0000000000000044 
       fffffc0000a57c00 0000000000000000 0000000000000000 00000000000200d2 
       ffffffffffe80000 0000000000000001 0000000000000000 fffffffc00000000 
Trace:
[<fffffc00003823e0>] vmap_page_range+0x1c4/0x264
[<fffffc0000381e0c>] alloc_pages_node+0x38/0x4c
[<fffffc00003824b4>] map_vm_area+0x34/0x58
[<fffffc0000382628>] __vmalloc_area_node+0x150/0x18c
[<fffffc00006e1bc8>] dm_ctl_ioctl+0x1c8/0x38c
[<fffffc00006dfe08>] dev_status+0x0/0x70
[<fffffc00003a14d8>] vfs_ioctl+0x3c/0xd0
[<fffffc00003a1ac4>] do_vfs_ioctl+0x558/0x5a8
[<fffffc00003a1b78>] sys_ioctl+0x64/0xa8
[<fffffc0000337708>] do_softirq+0x58/0x70
[<fffffc000031a404>] smp_percpu_timer_interrupt+0xa4/0xf0
[<fffffc00003a1b50>] sys_ioctl+0x3c/0xa8
[<fffffc0000310fa4>] entSys+0xa4/0xc0

---[ end trace a7919e7f17c0a725 ]---
------------[ cut here ]------------
WARNING: at /export/data/scm/linux-2.6/mm/vmalloc.c:104 vmap_page_range+0x1c4/0x264()
Modules linked in:
fffffc007e303ae8 0000000000000000 fffffc00003823e0 fffffffc00190000 
       fffffc0000aee000 fffffc0000a57ac0 6761705f70616d76 2b65676e61725f65 
       78302f3463317830 0000000000343632 fffffc0000a58fc8 00000000000200d2 
       0000000000000000 0000000000000000 0000000000000001 0000000000000044 
       fffffc0000a57c00 0000000000000000 0000000000000000 00000000000200d2 
       ffffffffffe80000 0000000000000001 0000000000000000 fffffffc00000000 
Trace:
[<fffffc00003823e0>] vmap_page_range+0x1c4/0x264
[<fffffc0000381e0c>] alloc_pages_node+0x38/0x4c
[<fffffc00003824b4>] map_vm_area+0x34/0x58
[<fffffc0000382628>] __vmalloc_area_node+0x150/0x18c
[<fffffc00006e1bc8>] dm_ctl_ioctl+0x1c8/0x38c
[<fffffc00006dfe08>] dev_status+0x0/0x70
[<fffffc00003a14d8>] vfs_ioctl+0x3c/0xd0
[<fffffc00003a1ac4>] do_vfs_ioctl+0x558/0x5a8
[<fffffc00003a1b78>] sys_ioctl+0x64/0xa8
[<fffffc0000392bf8>] sys_write+0x64/0x9c
[<fffffc00003a1b50>] sys_ioctl+0x3c/0xa8
[<fffffc0000310fa4>] entSys+0xa4/0xc0

---[ end trace a7919e7f17c0a725 ]---



For me they are occurring during invocation of 'lvm vgchange -a y'. 
The first call also fails, i.e. '0 volume groups activated',
while a second call succeeds and activates both of the VGs it should handle.

The traces above were taken from dmesg. They are not the first ones as there
are quite a lot of them  (perhaps one for every block device checked by
the lvm tool?) and so the initial ones already escaped the message buffer.


> Here's a full dmesg:
> http://eric.schwarzvogel.de/~klausman/kernel/2.6.28/alpha/dmesg_post_boot.txt
> 
> Note that it happens again later in the same dmesg. The messages
> always mention page allocation at the top of the trace.
> 
> The patch mentioned above is commit
> 1684f5ddd4c0c754f52c78eaa2c5c69ad09fb18c which fixes compilation
> on alpha (see http://bugzilla.kernel.org/show_bug.cgi?id=12289)
> The patch I used is here:
> http://eric.schwarzvogel.de/~klausman/kernel/2.6.28/alpha/pci.patch

this is my local fix to this build problem:


diff --git a/arch/alpha/include/asm/core_tsunami.h b/arch/alpha/include/asm/core_tsunami.h
index 58d4fe4..8e39ecf 100644
--- a/arch/alpha/include/asm/core_tsunami.h
+++ b/arch/alpha/include/asm/core_tsunami.h
@@ -2,7 +2,6 @@
 #define __ALPHA_TSUNAMI__H__
 
 #include <linux/types.h>
-#include <linux/pci.h>
 #include <asm/compiler.h>
 
 /*


I think some of the other core_*.h files need it, too.
 
> Here's my config:
> http://eric.schwarzvogel.de/~klausman/kernel/2.6.28/alpha/config.txt
> shortened by grep ^C:
> http://eric.schwarzvogel.de/~klausman/kernel/2.6.28/alpha/config-shortened.txt
> 
> The normal console output (catched via serial console) is here:
> http://eric.schwarzvogel.de/~klausman/kernel/2.6.28/alpha/console_output.txt
> 
> The machine in question is a Samsung UP1500. CPU is EV68AL on an
> ALI chipset (ali15x3). 

DS20, dual EV6
 
> Last kernel to work perfectly is a vanilla 2.6.27.10.
> 
> Before I dig into a rather time-consuming bisect, I'd like to
> hear informed opinions :)




bye,
Thorsten

-- 
| Thorsten Kranzkowski        Internet: dl8bcu@dl8bcu.de                      |
| Mobile: ++49 170 1876134       Snail: Kiebitzstr. 14, 49324 Melle, Germany  |
| Ampr: dl8bcu@db0lj.#rpl.deu.eu, dl8bcu@marvin.dl8bcu.ampr.org [44.130.8.19] |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
