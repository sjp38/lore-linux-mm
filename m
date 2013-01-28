Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 4E4DF6B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 04:10:59 -0500 (EST)
Date: Mon, 28 Jan 2013 11:10:39 +0200
From: Felipe Balbi <balbi@ti.com>
Subject: Page allocation failure on v3.8-rc5
Message-ID: <20130128091039.GG6871@arwen.pp.htv.fi>
Reply-To: <balbi@ti.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="p8PhoBjPxaQXD0vg"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux USB Mailing List <linux-usb@vger.kernel.org>, linux-mm@kvack.org

--p8PhoBjPxaQXD0vg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

The following page allocation failure triggers sometimes when I plug my
memory card reader on a USB port.


[850845.928795] usb 1-4: new high-speed USB device number 48 using ehci-pci
[850846.300702] usb 1-4: New USB device found, idVendor=3D0bda, idProduct=
=3D0119
[850846.300707] usb 1-4: New USB device strings: Mfr=3D1, Product=3D2, Seri=
alNumber=3D3
[850846.300711] usb 1-4: Product: USB2.0-CRW
[850846.300715] usb 1-4: Manufacturer: Generic
[850846.300718] usb 1-4: SerialNumber: 20090815198100000
[850846.302733] scsi86 : usb-storage 1-4:1.0
[850847.304359] scsi 86:0:0:0: Direct-Access     Generic- SD/MMC           =
1.00 PQ: 0 ANSI: 0 CCS
[850847.305734] sd 86:0:0:0: Attached scsi generic sg4 type 0
[850848.456294] sd 86:0:0:0: [sdd] 7911424 512-byte logical blocks: (4.05 G=
B/3.77 GiB)
[850848.457160] sd 86:0:0:0: [sdd] Write Protect is off
[850848.457166] sd 86:0:0:0: [sdd] Mode Sense: 03 00 00 00
[850848.458054] sd 86:0:0:0: [sdd] No Caching mode page present
[850848.458060] sd 86:0:0:0: [sdd] Assuming drive cache: write through
[850848.461502] sd 86:0:0:0: [sdd] No Caching mode page present
[850848.461507] sd 86:0:0:0: [sdd] Assuming drive cache: write through
[850848.461963] kworker/u:0: page allocation failure: order:4, mode:0x2000d0
[850848.461969] Pid: 7122, comm: kworker/u:0 Tainted: G        W    3.8.0-r=
c4+ #206
[850848.461972] Call Trace:
[850848.461984]  [<ffffffff810d02a8>] ? warn_alloc_failed+0x116/0x128
[850848.461991]  [<ffffffff810d31d9>] ? __alloc_pages_nodemask+0x6b5/0x751
[850848.462000]  [<ffffffff81106297>] ? kmem_getpages+0x59/0x129
[850848.462006]  [<ffffffff81106b88>] ? fallback_alloc+0x12f/0x1fc
[850848.462013]  [<ffffffff811071c7>] ? kmem_cache_alloc_trace+0x87/0xf6
[850848.462021]  [<ffffffff812a633c>] ? check_partition+0x28/0x1ac
[850848.462027]  [<ffffffff812a60bd>] ? rescan_partitions+0xa4/0x27c
[850848.462034]  [<ffffffff8113bcfb>] ? __blkdev_get+0x1ac/0x3d2
[850848.462040]  [<ffffffff8113c0b1>] ? blkdev_get+0x190/0x2d8
[850848.462046]  [<ffffffff8113b23f>] ? bdget+0x3b/0x12b
[850848.462052]  [<ffffffff812a41a6>] ? add_disk+0x268/0x3e2
[850848.462058]  [<ffffffff81382f3d>] ? sd_probe_async+0x11b/0x1cc
[850848.462066]  [<ffffffff81055f74>] ? async_run_entry_fn+0xa2/0x173
[850848.462072]  [<ffffffff81055ed2>] ? async_schedule+0x15/0x15
[850848.462079]  [<ffffffff8104bb79>] ? process_one_work+0x172/0x2ca
[850848.462084]  [<ffffffff8104b88a>] ? manage_workers+0x22a/0x23c
[850848.462090]  [<ffffffff81055ed2>] ? async_schedule+0x15/0x15
[850848.462096]  [<ffffffff8104bfa4>] ? worker_thread+0x11d/0x1b7
[850848.462102]  [<ffffffff8104be87>] ? rescuer_thread+0x18c/0x18c
[850848.462109]  [<ffffffff81050421>] ? kthread+0x86/0x8e
[850848.462116]  [<ffffffff8105039b>] ? __kthread_parkme+0x60/0x60
[850848.462125]  [<ffffffff814a306c>] ? ret_from_fork+0x7c/0xb0
[850848.462132]  [<ffffffff8105039b>] ? __kthread_parkme+0x60/0x60
[850848.462135] Mem-Info:
[850848.462138] Node 0 DMA per-cpu:
[850848.462143] CPU    0: hi:    0, btch:   1 usd:   0
[850848.462147] CPU    1: hi:    0, btch:   1 usd:   0
[850848.462151] CPU    2: hi:    0, btch:   1 usd:   0
[850848.462154] CPU    3: hi:    0, btch:   1 usd:   0
[850848.462158] CPU    4: hi:    0, btch:   1 usd:   0
[850848.462161] CPU    5: hi:    0, btch:   1 usd:   0
[850848.462165] CPU    6: hi:    0, btch:   1 usd:   0
[850848.462168] CPU    7: hi:    0, btch:   1 usd:   0
[850848.462171] Node 0 DMA32 per-cpu:
[850848.462176] CPU    0: hi:  186, btch:  31 usd:   0
[850848.462180] CPU    1: hi:  186, btch:  31 usd:   0
[850848.462183] CPU    2: hi:  186, btch:  31 usd:   0
[850848.462185] CPU    3: hi:  186, btch:  31 usd:   0
[850848.462187] CPU    4: hi:  186, btch:  31 usd:   0
[850848.462189] CPU    5: hi:  186, btch:  31 usd:   0
[850848.462192] CPU    6: hi:  186, btch:  31 usd:   0
[850848.462194] CPU    7: hi:  186, btch:  31 usd:   0
[850848.462196] Node 0 Normal per-cpu:
[850848.462199] CPU    0: hi:  186, btch:  31 usd:   0
[850848.462201] CPU    1: hi:  186, btch:  31 usd:   0
[850848.462203] CPU    2: hi:  186, btch:  31 usd:   0
[850848.462206] CPU    3: hi:  186, btch:  31 usd:   0
[850848.462208] CPU    4: hi:  186, btch:  31 usd:   0
[850848.462210] CPU    5: hi:  186, btch:  31 usd:   0
[850848.462212] CPU    6: hi:  186, btch:  31 usd:   0
[850848.462215] CPU    7: hi:  186, btch:  31 usd:   0
[850848.462222] active_anon:24837 inactive_anon:19982 isolated_anon:0
[850848.462222]  active_file:452273 inactive_file:418905 isolated_file:32
[850848.462222]  unevictable:0 dirty:2445 writeback:0 unstable:0
[850848.462222]  free:66997 slab_reclaimable:515526 slab_unreclaimable:12480
[850848.462222]  mapped:4698 shmem:82 pagetables:2389 bounce:0
[850848.462222]  free_cma:0
[850848.462228] Node 0 DMA free:15904kB min:168kB low:208kB high:252kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15680kB managed:15904kB =
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0=
kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB boun=
ce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[850848.462237] lowmem_reserve[]: 0 3012 6042 6042
[850848.462242] Node 0 DMA32 free:167276kB min:33604kB low:42004kB high:504=
04kB active_anon:0kB inactive_anon:3888kB active_file:1009068kB inactive_fi=
le:932732kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3=
084512kB managed:3051044kB mlocked:0kB dirty:3440kB writeback:0kB mapped:17=
48kB shmem:8kB slab_reclaimable:927596kB slab_unreclaimable:10460kB kernel_=
stack:64kB pagetables:336kB unstable:0kB bounce:0kB free_cma:0kB writeback_=
tmp:0kB pages_scanned:0 all_unreclaimable? no
[850848.462251] lowmem_reserve[]: 0 0 3030 3030
[850848.462256] Node 0 Normal free:84808kB min:33804kB low:42252kB high:507=
04kB active_anon:99348kB inactive_anon:76040kB active_file:800024kB inactiv=
e_file:742888kB unevictable:0kB isolated(anon):0kB isolated(file):128kB pre=
sent:3102720kB managed:3055508kB mlocked:0kB dirty:6340kB writeback:0kB map=
ped:17044kB shmem:320kB slab_reclaimable:1134508kB slab_unreclaimable:39460=
kB kernel_stack:2760kB pagetables:9220kB unstable:0kB bounce:0kB free_cma:0=
kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[850848.462265] lowmem_reserve[]: 0 0 0 0
[850848.462269] Node 0 DMA: 0*4kB 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 1*128k=
B (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) =3D 15904kB
[850848.462287] Node 0 DMA32: 15740*4kB (UEM) 8959*8kB (UEM) 1829*16kB (UEM=
) 52*32kB (UEM) 0*64kB 1*128kB (R) 1*256kB (R) 0*512kB 1*1024kB (R) 1*2048k=
B (R) 0*4096kB =3D 169016kB
[850848.462305] Node 0 Normal: 11559*4kB (UEM) 4308*8kB (UEM) 110*16kB (UEM=
) 2*32kB (R) 1*64kB (R) 0*128kB 1*256kB (R) 1*512kB (R) 1*1024kB (R) 1*2048=
kB (R) 0*4096kB =3D 86428kB
[850848.462324] 873577 total pagecache pages
[850848.462326] 2290 pages in swap cache
[850848.462328] Swap cache stats: add 100017, delete 97727, find 335070/338=
652
[850848.462330] Free swap  =3D 11973912kB
[850848.462332] Total swap =3D 12037116kB
[850848.499266] 1572848 pages RAM
[850848.499269] 41638 pages reserved
[850848.499271] 910353 pages shared
[850848.499272] 962690 pages non-shared
[850848.499276] SLAB: Unable to allocate memory on node 0 (gfp=3D0xd0)
[850848.499279]   cache: size-65536, object size: 65536, order: 4
[850848.499286]   node 0: slabs: 42/42, objs: 42/42, free: 0
[850848.502355] sd 86:0:0:0: [sdd] No Caching mode page present
[850848.502361] sd 86:0:0:0: [sdd] Assuming drive cache: write through
[850848.502366] sd 86:0:0:0: [sdd] Attached SCSI removable disk

--=20
balbi

--p8PhoBjPxaQXD0vg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRBkCPAAoJEIaOsuA1yqREHJAQAKCtR9kDixRHU5iM1MrvD1rp
Rhu4mkg5NRHRaa+TTSJS6Cyh9n5pJMsTuNDmrAa0DqAJgVWPluTLWpFdydqtkzNQ
xVPM/ZtpgDoHGxbG+ZRxamRh8AgROAyZWzZCM+krvWlPcABUIAnFs7T8nuHAq3I/
FK2N6gmAfInAbmLYxg1OY3dkXCsB9tFnssDQHpUK4yYJIIS1J0o2k7+5mg7awAE/
cOKEdbqrRI2RZP0A9QKwg3deMsMImj1cakZCqzHjx7fgzl7lXoMU5PE2BbWVHj+0
2TqFB2vJFQ8rz7b7xdP+I0SMJNr8uys42aZLQVl/HeZ44T6GMxi0WdrVDqKPIYaJ
s7fiLVaL9c+N2Qtakz1hEJE4NCDY8RcWGm/0KAGKfnUhNkKiodC6OoKKtze1uGLS
EadS2oftyDKYYNEARik3Y4NNr+6xdNBlIhRA2Q/CW0ZYHyrXdw30kf2B2/c8Fl6K
QlWDok+4Uwi6gnDJ5VkSDSt7uaOId9C6YlE1dLrrWk7EhckDgkITncrhjKJ+PlBu
xgHR3BK34gHEm7Pr6jdoKyN2quRDJGeYD9Q9z4cY8MerTzBOcLIaK/QJqBvGKCH/
RfQESGXosRUSgJCCFEYPeAhcJNOtWyVLApUAISjl2hyDKWek0hbTJCCQGVVvlwkS
ZS7UjZJHgxPFHLS4ZPtM
=1LJB
-----END PGP SIGNATURE-----

--p8PhoBjPxaQXD0vg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
