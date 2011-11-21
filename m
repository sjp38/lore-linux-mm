Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4E97E6B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 10:51:26 -0500 (EST)
Date: Mon, 21 Nov 2011 16:51:20 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111121155120.GA1673@x4.trippels.de>
References: <1321605837.30341.551.camel@debian>
 <20111118085436.GC1615@x4.trippels.de>
 <20111118120201.GA1642@x4.trippels.de>
 <1321836285.30341.554.camel@debian>
 <20111121080554.GB1625@x4.trippels.de>
 <20111121082445.GD1625@x4.trippels.de>
 <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121131531.GA1679@x4.trippels.de>
 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121153621.GA1678@x4.trippels.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20111121153621.GA1678@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, tj@kernel.org

On 2011.11.21 at 16:36 +0100, Markus Trippelsdorf wrote:
> On 2011.11.21 at 15:16 +0100, Eric Dumazet wrote:
> > Le lundi 21 novembre 2011 a 14:15 +0100, Markus Trippelsdorf a ecrit :
> > 
> > > I've enabled CONFIG_SLUB_DEBUG_ON and this is what happend:
> > > 
> > 
> > Thanks
> > 
> > Please continue to provide more samples.
> > 
> > There is something wrong somewhere, but where exactly, its hard to say.
> 
> =============================================================================
> BUG idr_layer_cache: Poison overwritten
> -----------------------------------------------------------------------------
> 
> INFO: 0xffff880215650800-0xffff880215650803. First byte 0x0 instead of 0x6b
> INFO: Slab 0xffffea0008559400 objects=18 used=18 fp=0x          (null) flags=0x4000000000004080
> INFO: Object 0xffff8802156506d0 @offset=1744 fp=0xffff880215650a38
> 
> Bytes b4 ffff8802156506c0: a4 6f fb ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  .o......ZZZZZZZZ
> Object ffff8802156506d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156506e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156506f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650700: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650710: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650720: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650730: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650740: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650750: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650760: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650770: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650780: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650790: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156507a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156507b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156507c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156507d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156507e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156507f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650800: 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ....kkkkkkkkkkkk
> Object ffff880215650810: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650820: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650830: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650840: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650850: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650860: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650870: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650880: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215650890: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156508a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156508b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156508c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156508d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156508e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
> Redzone ffff8802156508f0: bb bb bb bb bb bb bb bb                          ........
> Padding ffff880215650a30: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
> Pid: 1, comm: swapper Not tainted 3.2.0-rc2-00274-g6fe4c6d #71
> Call Trace:
>  [<ffffffff81101cf8>] ? print_section+0x38/0x40
>  [<ffffffff811021f3>] print_trailer+0xe3/0x150
>  [<ffffffff811023f0>] check_bytes_and_report+0xe0/0x100
>  [<ffffffff811031e6>] check_object+0x1c6/0x240
>  [<ffffffff812031f0>] ? idr_pre_get+0x60/0x90
>  [<ffffffff814c5c43>] alloc_debug_processing+0x62/0xe4
>  [<ffffffff814c64f1>] __slab_alloc.constprop.69+0x1a4/0x1e0
>  [<ffffffff8129ae77>] ? drm_property_create+0x47/0x110
>  [<ffffffff812031f0>] ? idr_pre_get+0x60/0x90
>  [<ffffffff81104db1>] kmem_cache_alloc+0x121/0x150
>  [<ffffffff812031f0>] ? idr_pre_get+0x60/0x90
>  [<ffffffff812031f0>] idr_pre_get+0x60/0x90
>  [<ffffffff8129870a>] drm_mode_object_get+0x6a/0xc0
>  [<ffffffff8129ae95>] drm_property_create+0x65/0x110
>  [<ffffffff8129b15d>] drm_mode_config_init+0xfd/0x190
>  [<ffffffff812e12ad>] radeon_modeset_init+0x1d/0x860
>  [<ffffffff813211c7>] ? radeon_acpi_init+0x87/0xc0
>  [<ffffffff812c37b8>] radeon_driver_load_kms+0xf8/0x150
>  [<ffffffff81295a06>] drm_get_pci_dev+0x186/0x2d0
>  [<ffffffff814bf1fd>] ? radeon_pci_probe+0x9e/0xb8
>  [<ffffffff814bf20f>] radeon_pci_probe+0xb0/0xb8
>  [<ffffffff8121be15>] pci_device_probe+0x75/0xa0
>  [<ffffffff81324e1a>] ? driver_sysfs_add+0x7a/0xb0
>  [<ffffffff81325021>] driver_probe_device+0x71/0x190
>  [<ffffffff813251db>] __driver_attach+0x9b/0xa0
>  [<ffffffff81325140>] ? driver_probe_device+0x190/0x190
>  [<ffffffff81323e0d>] bus_for_each_dev+0x4d/0x90
>  [<ffffffff813252f9>] driver_attach+0x19/0x20
>  [<ffffffff81324598>] bus_add_driver+0x188/0x250
>  [<ffffffff81325942>] driver_register+0x72/0x150
>  [<ffffffff81321de5>] ? device_add+0x75/0x600
>  [<ffffffff8121bb7d>] __pci_register_driver+0x5d/0xd0
>  [<ffffffff81295c54>] drm_pci_init+0x104/0x120
>  [<ffffffff818abefa>] ? ttm_init+0x62/0x62
>  [<ffffffff818abfe1>] radeon_init+0xe7/0xe9
>  [<ffffffff81890883>] do_one_initcall+0x7a/0x129
>  [<ffffffff818909cc>] kernel_init+0x9a/0x114
>  [<ffffffff814cddb4>] kernel_thread_helper+0x4/0x10
>  [<ffffffff81890932>] ? do_one_initcall+0x129/0x129
>  [<ffffffff814cddb0>] ? gs_change+0xb/0xb
> FIX idr_layer_cache: Restoring 0xffff880215650800-0xffff880215650803=0x6b
> 
> FIX idr_layer_cache: Marking all objects used

Running "slabinfo -v" later:

Nov 21 16:41:03 x4 kernel: =============================================================================
Nov 21 16:41:03 x4 kernel: BUG idr_layer_cache: Redzone overwritten
Nov 21 16:41:03 x4 kernel: -----------------------------------------------------------------------------
Nov 21 16:41:03 x4 kernel:
Nov 21 16:41:03 x4 kernel: INFO: 0xffff8802156508f0-0xffff8802156508f7. First byte 0xbb instead of 0xcc
Nov 21 16:41:03 x4 kernel: INFO: Slab 0xffffea0008559400 objects=18 used=18 fp=0x          (null) flags=0x4000000000004081
Nov 21 16:41:03 x4 kernel: INFO: Object 0xffff8802156506d0 @offset=1744 fp=0xffff880215650a38
Nov 21 16:41:03 x4 kernel:
Nov 21 16:41:03 x4 kernel: Bytes b4 ffff8802156506c0: a4 6f fb ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  .o......ZZZZZZZZ
Nov 21 16:41:03 x4 kernel: Object ffff8802156506d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156506e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156506f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650700: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650710: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650720: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650730: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650740: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650750: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650760: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650770: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650780: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650790: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156507a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156507b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156507c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156507d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156507e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156507f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650800: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650810: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650820: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650830: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650840: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650850: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650860: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650870: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650880: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff880215650890: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156508a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156508b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156508c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156508d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:41:03 x4 kernel: Object ffff8802156508e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
Nov 21 16:41:03 x4 kernel: Redzone ffff8802156508f0: bb bb bb bb bb bb bb bb                          ........
Nov 21 16:41:03 x4 kernel: Padding ffff880215650a30: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
Nov 21 16:41:03 x4 kernel: Pid: 12278, comm: slabinfo Not tainted 3.2.0-rc2-00274-g6fe4c6d #71
Nov 21 16:41:03 x4 kernel: Call Trace:
Nov 21 16:41:03 x4 kernel: [<ffffffff81101cf8>] ? print_section+0x38/0x40
Nov 21 16:41:03 x4 kernel: [<ffffffff811021f3>] print_trailer+0xe3/0x150
Nov 21 16:41:03 x4 kernel: [<ffffffff811023f0>] check_bytes_and_report+0xe0/0x100
Nov 21 16:41:03 x4 kernel: [<ffffffff811031a3>] check_object+0x183/0x240
Nov 21 16:41:03 x4 kernel: [<ffffffff81103cc0>] validate_slab_slab+0x1c0/0x230
Nov 21 16:41:03 x4 kernel: [<ffffffff811061f6>] validate_store+0xf6/0x190
Nov 21 16:41:03 x4 kernel: [<ffffffff8110163c>] slab_attr_store+0x1c/0x30
Nov 21 16:41:03 x4 kernel: [<ffffffff811634f8>] sysfs_write_file+0xc8/0x140
Nov 21 16:41:03 x4 kernel: [<ffffffff8110dc93>] vfs_write+0xa3/0x160
Nov 21 16:41:03 x4 kernel: [<ffffffff8110de25>] sys_write+0x45/0x90
Nov 21 16:41:03 x4 kernel: [<ffffffff814ccbfb>] system_call_fastpath+0x16/0x1b
Nov 21 16:41:03 x4 kernel: FIX idr_layer_cache: Restoring 0xffff8802156508f0-0xffff8802156508f7=0xcc
Nov 21 16:41:03 x4 kernel:
Nov 21 16:42:07 x4 kernel: =============================================================================
Nov 21 16:42:07 x4 kernel: BUG idr_layer_cache: Redzone overwritten
Nov 21 16:42:07 x4 kernel: -----------------------------------------------------------------------------
Nov 21 16:42:07 x4 kernel:
Nov 21 16:42:07 x4 kernel: INFO: 0xffff880215650c58-0xffff880215650c5f. First byte 0xbb instead of 0xcc
Nov 21 16:42:07 x4 kernel: INFO: Slab 0xffffea0008559400 objects=18 used=18 fp=0x          (null) flags=0x4000000000004081
Nov 21 16:42:07 x4 kernel: INFO: Object 0xffff880215650a38 @offset=2616 fp=0xffff880215650da0
Nov 21 16:42:07 x4 kernel:
Nov 21 16:42:07 x4 kernel: Bytes b4 ffff880215650a28: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
Nov 21 16:42:07 x4 kernel: Object ffff880215650a38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650a48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650a58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650a68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650a78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650a88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650a98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650aa8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650ab8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650ac8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650ad8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650ae8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650af8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650b08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650b18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650b28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650b38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650b48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650b58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650b68: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650b78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650b88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650b98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650ba8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650bb8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650bc8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650bd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650be8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650bf8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650c08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650c18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650c28: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650c38: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Nov 21 16:42:07 x4 kernel: Object ffff880215650c48: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
Nov 21 16:42:07 x4 kernel: Redzone ffff880215650c58: bb bb bb bb bb bb bb bb                          ........
Nov 21 16:42:07 x4 kernel: Padding ffff880215650d98: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
Nov 21 16:42:07 x4 kernel: Pid: 12924, comm: slabinfo Not tainted 3.2.0-rc2-00274-g6fe4c6d #71
Nov 21 16:42:07 x4 kernel: Call Trace:
Nov 21 16:42:07 x4 kernel: [<ffffffff81101cf8>] ? print_section+0x38/0x40
Nov 21 16:42:07 x4 kernel: [<ffffffff811021f3>] print_trailer+0xe3/0x150
Nov 21 16:42:07 x4 kernel: [<ffffffff811023f0>] check_bytes_and_report+0xe0/0x100
Nov 21 16:42:07 x4 kernel: [<ffffffff811031a3>] check_object+0x183/0x240
Nov 21 16:42:07 x4 kernel: [<ffffffff81103cc0>] validate_slab_slab+0x1c0/0x230
Nov 21 16:42:07 x4 kernel: [<ffffffff811061f6>] validate_store+0xf6/0x190
Nov 21 16:42:07 x4 kernel: [<ffffffff8110163c>] slab_attr_store+0x1c/0x30
Nov 21 16:42:07 x4 kernel: [<ffffffff811634f8>] sysfs_write_file+0xc8/0x140
Nov 21 16:42:07 x4 kernel: [<ffffffff8110dc93>] vfs_write+0xa3/0x160
Nov 21 16:42:07 x4 kernel: [<ffffffff8110de25>] sys_write+0x45/0x90
Nov 21 16:42:07 x4 kernel: [<ffffffff814ccbfb>] system_call_fastpath+0x16/0x1b
Nov 21 16:42:07 x4 kernel: FIX idr_layer_cache: Restoring 0xffff880215650c58-0xffff880215650c5f=0xcc

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
