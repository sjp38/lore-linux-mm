Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1DFAC6B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 10:36:32 -0500 (EST)
Date: Mon, 21 Nov 2011 16:36:21 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111121153621.GA1678@x4.trippels.de>
References: <20111118075521.GB1615@x4.trippels.de>
 <1321605837.30341.551.camel@debian>
 <20111118085436.GC1615@x4.trippels.de>
 <20111118120201.GA1642@x4.trippels.de>
 <1321836285.30341.554.camel@debian>
 <20111121080554.GB1625@x4.trippels.de>
 <20111121082445.GD1625@x4.trippels.de>
 <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121131531.GA1679@x4.trippels.de>
 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, tj@kernel.org

On 2011.11.21 at 15:16 +0100, Eric Dumazet wrote:
> Le lundi 21 novembre 2011 a 14:15 +0100, Markus Trippelsdorf a ecrit :
> 
> > I've enabled CONFIG_SLUB_DEBUG_ON and this is what happend:
> > 
> 
> Thanks
> 
> Please continue to provide more samples.
> 
> There is something wrong somewhere, but where exactly, its hard to say.

New sample. This one points to lib/idr.c:

[drm] Initialized drm 1.1.0 20060810
[drm] radeon defaulting to kernel modesetting.
[drm] radeon kernel modesetting enabled.
radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
radeon 0000:01:05.0: setting latency timer to 64
[drm] initializing kernel modesetting (RS780 0x1002:0x9614 0x1043:0x834D).
[drm] register mmio base: 0xFBEE0000
[drm] register mmio size: 65536
ATOM BIOS: 113
radeon 0000:01:05.0: VRAM: 128M 0x00000000C0000000 - 0x00000000C7FFFFFF (128M used)
radeon 0000:01:05.0: GTT: 512M 0x00000000A0000000 - 0x00000000BFFFFFFF
[drm] Detected VRAM RAM=128M, BAR=128M
[drm] RAM width 32bits DDR
[TTM] Zone  kernel: Available graphics memory: 4083428 kiB.
[TTM] Zone   dma32: Available graphics memory: 2097152 kiB.
[TTM] Initializing pool allocator.
[drm] radeon: 128M of VRAM memory ready
[drm] radeon: 512M of GTT memory ready.
[drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[drm] Driver supports precise vblank timestamp query.
[drm] radeon: irq initialized.
[drm] GART: num cpu pages 131072, num gpu pages 131072
[drm] Loading RS780 Microcode
[drm] PCIE GART of 512M enabled (table at 0x00000000C0040000).
radeon 0000:01:05.0: WB enabled
[drm] ring test succeeded in 1 usecs
[drm] radeon: ib pool ready.
[drm] ib test succeeded in 0 usecs
=============================================================================
BUG idr_layer_cache: Poison overwritten
-----------------------------------------------------------------------------

INFO: 0xffff880215650800-0xffff880215650803. First byte 0x0 instead of 0x6b
INFO: Slab 0xffffea0008559400 objects=18 used=18 fp=0x          (null) flags=0x4000000000004080
INFO: Object 0xffff8802156506d0 @offset=1744 fp=0xffff880215650a38

Bytes b4 ffff8802156506c0: a4 6f fb ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  .o......ZZZZZZZZ
Object ffff8802156506d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156506e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156506f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650700: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650710: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650720: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650730: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650740: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650750: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650760: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650770: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650780: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650790: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156507a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156507b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156507c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156507d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156507e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156507f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650800: 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ....kkkkkkkkkkkk
Object ffff880215650810: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650820: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650830: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650840: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650850: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650860: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650870: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650880: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880215650890: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156508a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156508b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156508c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156508d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff8802156508e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
Redzone ffff8802156508f0: bb bb bb bb bb bb bb bb                          ........
Padding ffff880215650a30: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
Pid: 1, comm: swapper Not tainted 3.2.0-rc2-00274-g6fe4c6d #71
Call Trace:
 [<ffffffff81101cf8>] ? print_section+0x38/0x40
 [<ffffffff811021f3>] print_trailer+0xe3/0x150
 [<ffffffff811023f0>] check_bytes_and_report+0xe0/0x100
 [<ffffffff811031e6>] check_object+0x1c6/0x240
 [<ffffffff812031f0>] ? idr_pre_get+0x60/0x90
 [<ffffffff814c5c43>] alloc_debug_processing+0x62/0xe4
 [<ffffffff814c64f1>] __slab_alloc.constprop.69+0x1a4/0x1e0
 [<ffffffff8129ae77>] ? drm_property_create+0x47/0x110
 [<ffffffff812031f0>] ? idr_pre_get+0x60/0x90
 [<ffffffff81104db1>] kmem_cache_alloc+0x121/0x150
 [<ffffffff812031f0>] ? idr_pre_get+0x60/0x90
 [<ffffffff812031f0>] idr_pre_get+0x60/0x90
 [<ffffffff8129870a>] drm_mode_object_get+0x6a/0xc0
 [<ffffffff8129ae95>] drm_property_create+0x65/0x110
 [<ffffffff8129b15d>] drm_mode_config_init+0xfd/0x190
 [<ffffffff812e12ad>] radeon_modeset_init+0x1d/0x860
 [<ffffffff813211c7>] ? radeon_acpi_init+0x87/0xc0
 [<ffffffff812c37b8>] radeon_driver_load_kms+0xf8/0x150
 [<ffffffff81295a06>] drm_get_pci_dev+0x186/0x2d0
 [<ffffffff814bf1fd>] ? radeon_pci_probe+0x9e/0xb8
 [<ffffffff814bf20f>] radeon_pci_probe+0xb0/0xb8
 [<ffffffff8121be15>] pci_device_probe+0x75/0xa0
 [<ffffffff81324e1a>] ? driver_sysfs_add+0x7a/0xb0
 [<ffffffff81325021>] driver_probe_device+0x71/0x190
 [<ffffffff813251db>] __driver_attach+0x9b/0xa0
 [<ffffffff81325140>] ? driver_probe_device+0x190/0x190
 [<ffffffff81323e0d>] bus_for_each_dev+0x4d/0x90
 [<ffffffff813252f9>] driver_attach+0x19/0x20
 [<ffffffff81324598>] bus_add_driver+0x188/0x250
 [<ffffffff81325942>] driver_register+0x72/0x150
 [<ffffffff81321de5>] ? device_add+0x75/0x600
 [<ffffffff8121bb7d>] __pci_register_driver+0x5d/0xd0
 [<ffffffff81295c54>] drm_pci_init+0x104/0x120
 [<ffffffff818abefa>] ? ttm_init+0x62/0x62
 [<ffffffff818abfe1>] radeon_init+0xe7/0xe9
 [<ffffffff81890883>] do_one_initcall+0x7a/0x129
 [<ffffffff818909cc>] kernel_init+0x9a/0x114
 [<ffffffff814cddb4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81890932>] ? do_one_initcall+0x129/0x129
 [<ffffffff814cddb0>] ? gs_change+0xb/0xb
FIX idr_layer_cache: Restoring 0xffff880215650800-0xffff880215650803=0x6b

FIX idr_layer_cache: Marking all objects used
[drm] Radeon Display Connectors
[drm] Connector 0:
[drm]   VGA
[drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4c 0x7e4c
[drm]   Encoders:
[drm]     CRT1: INTERNAL_KLDSCP_DAC1
[drm] Connector 1:
[drm]   DVI-D
[drm]   HPD3
[drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5c 0x7e5c
[drm]   Encoders:
[drm]     DFP3: INTERNAL_KLDSCP_LVTMA
[drm] radeon: power management initialized
[drm] fb mappable at 0xF0142000
[drm] vram apper at 0xF0000000
[drm] size 7299072
[drm] fb depth is 24
[drm]    pitch is 6912
fbcon: radeondrmfb (fb0) is primary device
Console: switching to colour frame buffer device 131x105
...

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
