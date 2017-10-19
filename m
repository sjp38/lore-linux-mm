Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 383546B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 00:03:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d28so4852921pfe.1
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 21:03:34 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l11si3388963pgq.28.2017.10.18.21.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 21:03:32 -0700 (PDT)
Date: Thu, 19 Oct 2017 11:56:41 +0800
From: "Du, Changbin" <changbin.du@intel.com>
Subject: Re: swapper/0: page allocation failure: order:0,
 mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
 nodemask=(null)
Message-ID: <20171019035641.GB23773@intel.com>
References: <CABXGCsPEkwzKUU9OPRDOMue7TpWa4axTWg0FbXZAq+JZmoubGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3uo+9/B/ebqu+fSQ"
Content-Disposition: inline
In-Reply-To: <CABXGCsPEkwzKUU9OPRDOMue7TpWa4axTWg0FbXZAq+JZmoubGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Cc: linux-mm@kvack.org, changbin.du@intel.com


--3uo+9/B/ebqu+fSQ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 19, 2017 at 01:16:48AM +0500, =D0=9C=D0=B8=D1=85=D0=B0=D0=B8=D0=
=BB =D0=93=D0=B0=D0=B2=D1=80=D0=B8=D0=BB=D0=BE=D0=B2 wrote:
> Hi! Who knows what is happened here?
> Bug?
>=20
> [ 2880.745242] swapper/0: page allocation failure: order:0,
> mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
I am curious about this, how can slub try to alloc compound page but the or=
der
is 0? This is wrong.

> nodemask=3D(null)
> [ 2880.745311] swapper/0 cpuset=3D/ mems_allowed=3D0-1023
> [ 2880.745504] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
> 4.13.6-300.fc27.x86_64+debug #1
> [ 2880.745505] Hardware name: Gigabyte Technology Co., Ltd.
> Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
> [ 2880.745506] Call Trace:
> [ 2880.745508]  <IRQ>
> [ 2880.745513]  dump_stack+0x8e/0xd6
> [ 2880.745517]  warn_alloc+0x114/0x1c0
> [ 2880.745525]  __alloc_pages_slowpath+0x104b/0x1100
> [ 2880.745533]  ? sched_clock+0x9/0x10
> [ 2880.745537]  ? get_partial_node.isra.67+0x226/0x2e0
> [ 2880.745542]  ? __lock_is_held+0x65/0xb0
> [ 2880.745548]  __alloc_pages_nodemask+0x351/0x3e0
> [ 2880.745554]  alloc_pages_current+0x6a/0xe0
> [ 2880.745557]  new_slab+0x440/0x740
> [ 2880.745559]  ? __slab_alloc+0x51/0x90
> [ 2880.745565]  ___slab_alloc+0x3eb/0x5e0
> [ 2880.745569]  ? radix_tree_node_alloc.constprop.18+0x46/0xe0
> [ 2880.745575]  ? radix_tree_node_alloc.constprop.18+0x46/0xe0
> [ 2880.745578]  __slab_alloc+0x51/0x90
> [ 2880.745580]  ? __slab_alloc+0x51/0x90
> [ 2880.745584]  kmem_cache_alloc+0x235/0x2e0
> [ 2880.745585]  ? radix_tree_node_alloc.constprop.18+0x46/0xe0
> [ 2880.745589]  radix_tree_node_alloc.constprop.18+0x46/0xe0
> [ 2880.745592]  __radix_tree_create+0x16d/0x1d0
> [ 2880.745597]  __radix_tree_insert+0x45/0x210
> [ 2880.745604]  add_dma_entry+0xbf/0x170
> [ 2880.745609]  debug_dma_map_sg+0x11a/0x170
> [ 2880.745614]  ata_qc_issue+0x1de/0x380
> [ 2880.745618]  ? ata_scsi_var_len_cdb_xlat+0x30/0x30
> [ 2880.745620]  ata_scsi_translate+0xcf/0x1a0
> [ 2880.745624]  ata_scsi_queuecmd+0xa4/0x210
> [ 2880.745628]  scsi_dispatch_cmd+0xf9/0x390
> [ 2880.745632]  scsi_request_fn+0x4d6/0x6e0
> [ 2880.745638]  __blk_run_queue+0x5c/0xc0
> [ 2880.745640]  blk_run_queue+0x30/0x50
> [ 2880.745643]  scsi_run_queue+0x23f/0x310
> [ 2880.745648]  scsi_end_request+0xf0/0x1d0
> [ 2880.745652]  scsi_io_completion+0x283/0x6c0
> [ 2880.745657]  scsi_finish_command+0xe4/0x120
> [ 2880.745661]  scsi_softirq_done+0x105/0x160
> [ 2880.745664]  blk_done_softirq+0xa8/0xd0
> [ 2880.745669]  __do_softirq+0xce/0x4ed
> [ 2880.745682]  ? sched_clock+0x9/0x10
> [ 2880.745684]  ? sched_clock+0x9/0x10
> [ 2880.745689]  irq_exit+0x10f/0x120
> [ 2880.745692]  do_IRQ+0x92/0x110
> [ 2880.745696]  common_interrupt+0x9d/0x9d
> [ 2880.745698] RIP: 0010:cpuidle_enter_state+0x135/0x390
> [ 2880.745700] RSP: 0018:ffffffffafe03dc0 EFLAGS: 00000206 ORIG_RAX:
> ffffffffffffff2e
> [ 2880.745703] RAX: ffffffffafe18500 RBX: 0000029eb9c9a7f7 RCX: 000000000=
0000000
> [ 2880.745704] RDX: ffffffffafe18500 RSI: 0000000000000001 RDI: ffffffffa=
fe18500
> [ 2880.745705] RBP: ffffffffafe03e00 R08: 0000000000000075 R09: 000000000=
0000000
> [ 2880.745706] R10: 0000000000000000 R11: 0000000000000000 R12: ffffe15e7=
ee00000
> [ 2880.745707] R13: 0000000000000000 R14: 0000000000000001 R15: ffffffffb=
00634d8
> [ 2880.745709]  </IRQ>
> [ 2880.745721]  cpuidle_enter+0x17/0x20
> [ 2880.745733]  call_cpuidle+0x23/0x40
> [ 2880.745735]  do_idle+0x194/0x1f0
> [ 2880.745739]  cpu_startup_entry+0x73/0x80
> [ 2880.745742]  rest_init+0xd5/0xe0
> [ 2880.745745]  start_kernel+0x4f4/0x515
> [ 2880.745749]  ? early_idt_handler_array+0x120/0x120
> [ 2880.745751]  x86_64_start_reservations+0x24/0x26
> [ 2880.745754]  x86_64_start_kernel+0x13e/0x161
> [ 2880.745759]  secondary_startup_64+0x9f/0x9f
> [ 2880.745847] SLUB: Unable to allocate memory on node -1,
> gfp=3D0x1000000(GFP_NOWAIT)
> [ 2880.745849]   cache: radix_tree_node, object size: 576, buffer
> size: 584, default order: 2, min order: 0
> [ 2880.745851]   node 0: slabs: 3526, objs: 98203, free: 0
> [ 2880.745871] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
>=20
>=20
>=20
>=20
> --
> Best Regards,
> Mike Gavrilov.
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--=20
Thanks,
Changbin Du

--3uo+9/B/ebqu+fSQ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZ6CJ5AAoJEAanuZwLnPNUDY0IAJxly5YBXktwcdAv7Dw3DMnM
6GAuT4oy968j3qqk7eOYIfB/pCktIkEBZW/3F4W87HH0nqKZHhOsp0dDO+XQCD37
SMva69Fqec7OrnF+kXAVo0kwRPHjHR+HilHbvXIbfnaUthTOhq7vd5yTPFQDipnK
TF787iJYcx2wTfTZk52zBHOeNa1QrKbq2QYyxi3F1/zJiPA749H079VhB+lCAaR9
hJVryXu3Q5SUKqodWOOsSAe+Rrv6DrzKAJD5AmBWAyGOY62rmDiHeFy3F0RBz92K
HD2Oe0wKjPgAlrZVoDekSgkUVj13QE4EY9M1VPwDPaRafKIKaWADy52E0qwDxho=
=MTYy
-----END PGP SIGNATURE-----

--3uo+9/B/ebqu+fSQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
