Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 047576B0009
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 03:41:33 -0500 (EST)
Received: from dlelxv30.itg.ti.com ([172.17.2.17])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id r0Q8fW7D024670
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 02:41:33 -0600
Received: from DFLE72.ent.ti.com (dfle72.ent.ti.com [128.247.5.109])
	by dlelxv30.itg.ti.com (8.13.8/8.13.8) with ESMTP id r0Q8fWtZ026269
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 02:41:32 -0600
Received: from localhost (h78-8.vpn.ti.com [172.24.78.8])	by
 dlelxv22.itg.ti.com (8.13.8/8.13.8) with ESMTP id r0Q8fVU5032533	for
 <linux-mm@kvack.org>; Sat, 26 Jan 2013 02:41:32 -0600
MIME-Version: 1.0
Date: Fri, 25 Jan 2013 21:40:25 +0200
From: Felipe Balbi <balbi@ti.com>
Subject: v3.8-rc4: Page Allocation Failure
Message-ID: <20130125194025.GA4520@arwen.pp.htv.fi>
Reply-To: <balbi@ti.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux USB Mailing List <linux-usb@vger.kernel.org>

--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi folks,

This now started to happen on my development PC. I'm running v3.8-rc4
with my gadget-specific patches (nothing on the Host side, no gadget
code is running here).

Below you will find dmesg of the failure which just triggered. Looks
like it's related to the async function call problem which is going on,
just thought I'd report anyway ;-)

[632211.063220] usb 1-4: USB disconnect, device number 44
[632213.132568] usb 1-4: new high-speed USB device number 45 using ehci-pci
[632213.249429] usb 1-4: New USB device found, idVendor=3D0951, idProduct=
=3D1607
[632213.249434] usb 1-4: New USB device strings: Mfr=3D1, Product=3D2, Seri=
alNumber=3D3
[632213.249438] usb 1-4: Product: DataTraveler 2.0
[632213.249441] usb 1-4: Manufacturer: Kingston
[632213.249444] usb 1-4: SerialNumber: 001478090230A9105FFF0014
[632213.250497] scsi81 : usb-storage 1-4:1.0
[632214.251418] scsi 81:0:0:0: Direct-Access     Kingston DataTraveler 2.0 =
1.00 PQ: 0 ANSI: 2
[632214.252774] sd 81:0:0:0: Attached scsi generic sg4 type 0
[632214.253281] sd 81:0:0:0: [sdd] 31506432 512-byte logical blocks: (16.1 =
GB/15.0 GiB)
[632214.253995] sd 81:0:0:0: [sdd] Write Protect is off
[632214.254000] sd 81:0:0:0: [sdd] Mode Sense: 23 00 00 00
[632214.254768] sd 81:0:0:0: [sdd] No Caching mode page present
[632214.254774] sd 81:0:0:0: [sdd] Assuming drive cache: write through
[632214.258429] sd 81:0:0:0: [sdd] No Caching mode page present
[632214.258434] sd 81:0:0:0: [sdd] Assuming drive cache: write through
[632214.259066] kworker/u:3: page allocation failure: order:4, mode:0x2000d0
[632214.259071] Pid: 15804, comm: kworker/u:3 Tainted: G        W    3.8.0-=
rc4+ #206
[632214.259073] Call Trace:
[632214.259083]  [<ffffffff810d02a8>] ? warn_alloc_failed+0x116/0x128
[632214.259088]  [<ffffffff810d31d9>] ? __alloc_pages_nodemask+0x6b5/0x751
[632214.259096]  [<ffffffff81106297>] ? kmem_getpages+0x59/0x129
[632214.259100]  [<ffffffff81106b88>] ? fallback_alloc+0x12f/0x1fc
[632214.259105]  [<ffffffff811071c7>] ? kmem_cache_alloc_trace+0x87/0xf6
[632214.259111]  [<ffffffff812a633c>] ? check_partition+0x28/0x1ac
[632214.259116]  [<ffffffff812a60bd>] ? rescan_partitions+0xa4/0x27c
[632214.259121]  [<ffffffff8113bcfb>] ? __blkdev_get+0x1ac/0x3d2
[632214.259125]  [<ffffffff8113c0b1>] ? blkdev_get+0x190/0x2d8
[632214.259130]  [<ffffffff8113b23f>] ? bdget+0x3b/0x12b
[632214.259173]  [<ffffffff812a41a6>] ? add_disk+0x268/0x3e2
[632214.259178]  [<ffffffff81382f3d>] ? sd_probe_async+0x11b/0x1cc
[632214.259184]  [<ffffffff81055f74>] ? async_run_entry_fn+0xa2/0x173
[632214.259189]  [<ffffffff81055ed2>] ? async_schedule+0x15/0x15
[632214.259194]  [<ffffffff8104bb79>] ? process_one_work+0x172/0x2ca
[632214.259199]  [<ffffffff81055ed2>] ? async_schedule+0x15/0x15
[632214.259203]  [<ffffffff8104bfa4>] ? worker_thread+0x11d/0x1b7
[632214.259207]  [<ffffffff8104be87>] ? rescuer_thread+0x18c/0x18c
[632214.259212]  [<ffffffff81050421>] ? kthread+0x86/0x8e
[632214.259218]  [<ffffffff8105039b>] ? __kthread_parkme+0x60/0x60
[632214.259233]  [<ffffffff814a306c>] ? ret_from_fork+0x7c/0xb0
[632214.259241]  [<ffffffff8105039b>] ? __kthread_parkme+0x60/0x60
[632214.259244] Mem-Info:
[632214.259246] Node 0 DMA per-cpu:
[632214.259249] CPU    0: hi:    0, btch:   1 usd:   0
[632214.259252] CPU    1: hi:    0, btch:   1 usd:   0
[632214.259254] CPU    2: hi:    0, btch:   1 usd:   0
[632214.259256] CPU    3: hi:    0, btch:   1 usd:   0
[632214.259258] CPU    4: hi:    0, btch:   1 usd:   0
[632214.259261] CPU    5: hi:    0, btch:   1 usd:   0
[632214.259263] CPU    6: hi:    0, btch:   1 usd:   0
[632214.259269] CPU    7: hi:    0, btch:   1 usd:   0
[632214.259276] Node 0 DMA32 per-cpu:
[632214.259284] CPU    0: hi:  186, btch:  31 usd:   0
[632214.259286] CPU    1: hi:  186, btch:  31 usd:   0
[632214.259288] CPU    2: hi:  186, btch:  31 usd:   0
[632214.259291] CPU    3: hi:  186, btch:  31 usd:   0
[632214.259293] CPU    4: hi:  186, btch:  31 usd:   0
[632214.259295] CPU    5: hi:  186, btch:  31 usd:   0
[632214.259297] CPU    6: hi:  186, btch:  31 usd:   0
[632214.259299] CPU    7: hi:  186, btch:  31 usd:   0
[632214.259301] Node 0 Normal per-cpu:
[632214.259311] CPU    0: hi:  186, btch:  31 usd:   0
[632214.259319] CPU    1: hi:  186, btch:  31 usd:   0
[632214.259324] CPU    2: hi:  186, btch:  31 usd:   0
[632214.259326] CPU    3: hi:  186, btch:  31 usd:   0
[632214.259328] CPU    4: hi:  186, btch:  31 usd:   0
[632214.259330] CPU    5: hi:  186, btch:  31 usd:   0
[632214.259333] CPU    6: hi:  186, btch:  31 usd:   0
[632214.259335] CPU    7: hi:  186, btch:  31 usd:   0
[632214.259342] active_anon:8098 inactive_anon:16550 isolated_anon:0
[632214.259342]  active_file:400259 inactive_file:523089 isolated_file:0
[632214.259342]  unevictable:0 dirty:22 writeback:0 unstable:0
[632214.259342]  free:77221 slab_reclaimable:474822 slab_unreclaimable:12466
[632214.259342]  mapped:4599 shmem:33 pagetables:2364 bounce:0
[632214.259342]  free_cma:0
[632214.259348] Node 0 DMA free:15904kB min:168kB low:208kB high:252kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:15680kB managed:15904kB =
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0=
kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB boun=
ce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[632214.259362] lowmem_reserve[]: 0 3012 6042 6042
[632214.259377] Node 0 DMA32 free:160256kB min:33604kB low:42004kB high:504=
04kB active_anon:0kB inactive_anon:3964kB active_file:837628kB inactive_fil=
e:1170824kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3=
084512kB managed:3051044kB mlocked:0kB dirty:0kB writeback:0kB mapped:3180k=
B shmem:0kB slab_reclaimable:870264kB slab_unreclaimable:9184kB kernel_stac=
k:64kB pagetables:336kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:=
0kB pages_scanned:0 all_unreclaimable? no
[632214.259387] lowmem_reserve[]: 0 0 3030 3030
[632214.259391] Node 0 Normal free:132724kB min:33804kB low:42252kB high:50=
704kB active_anon:32392kB inactive_anon:62236kB active_file:763408kB inacti=
ve_file:921532kB unevictable:0kB isolated(anon):0kB isolated(file):0kB pres=
ent:3102720kB managed:3055508kB mlocked:0kB dirty:88kB writeback:0kB mapped=
:15216kB shmem:132kB slab_reclaimable:1029024kB slab_unreclaimable:40680kB =
kernel_stack:2664kB pagetables:9120kB unstable:0kB bounce:0kB free_cma:0kB =
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[632214.259400] lowmem_reserve[]: 0 0 0 0
[632214.259405] Node 0 DMA: 0*4kB 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 1*128k=
B (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) =3D 15904kB
[632214.259430] Node 0 DMA32: 19896*4kB (UEM) 8401*8kB (UEM) 613*16kB (UEM)=
 0*32kB 1*64kB (R) 1*128kB (R) 1*256kB (R) 1*512kB (R) 1*1024kB (R) 1*2048k=
B (R) 0*4096kB =3D 160632kB
[632214.259448] Node 0 Normal: 15176*4kB (UEM) 8586*8kB (UEM) 114*16kB (UEM=
) 2*32kB (R) 3*64kB (R) 0*128kB 1*256kB (R) 1*512kB (R) 0*1024kB 1*2048kB (=
R) 0*4096kB =3D 134288kB
[632214.259466] 925472 total pagecache pages
[632214.259468] 2094 pages in swap cache
[632214.259471] Swap cache stats: add 99298, delete 97204, find 289450/2929=
24
[632214.259473] Free swap  =3D 11971828kB
[632214.259475] Total swap =3D 12037116kB
[632214.298163] 1572848 pages RAM
[632214.298166] 41638 pages reserved
[632214.298168] 1050385 pages shared
[632214.298169] 783468 pages non-shared
[632214.298173] SLAB: Unable to allocate memory on node 0 (gfp=3D0xd0)
[632214.298176]   cache: size-65536, object size: 65536, order: 4
[632214.298182]   node 0: slabs: 42/42, objs: 42/42, free: 0
[632214.300806] sd 81:0:0:0: [sdd] No Caching mode page present
[632214.300812] sd 81:0:0:0: [sdd] Assuming drive cache: write through
[632214.300817] sd 81:0:0:0: [sdd] Attached SCSI removable disk

--=20
balbi

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRAt+pAAoJEIaOsuA1yqREHsoP/2gv6Ac64ve4mfTfz6eOad7A
aZsO06+145fQj6qQ7lrkNrNE5bElHcwxzDdphzCianu4bnSloZsMyJXr6hTDXeQV
L6A0LXq2htHgCI9L3uzSX+C74l80n7aBXwCITEwX68AaeHGet1v08vIxF3oVUkcT
nr2U41GxSdS/3xAYfKJpjxS+cKsivGFvQDC7iW0OlFVm5+85HZ1qfRBQLGBZgIXT
FQZadzx0dUFDJjhFH5OaN9HQnY+gWZe9UreVxmA+hOEQ3pqlMaaLNVrJqXxckFP7
yN8RZqBtNLwKadYHWk4rQ69OboLQoV/wqHTcr8dcmUQeAVX8//bezLWuBCeegKxM
GNsJhZEPkofWBjMwf0BHNMf0sJdIHF+phuIw26whRUYRo7n+KltOYOISfbirMxON
MUYMeMYm9DkeHtq5ZZb/NysZM7yalSatrOdWS4pA0s9VdP9jYsjmI/m7XtOfMWbq
8cBUNy3PPmrT1FVb1X+6K14wFBfmJD0QnnUgsh60Tsxv480cIslwYpoku1TU+KOV
W0W06fN/Q4iN1UPz5OWoe6vKsmx1ADJUNFEySLVuzDZTzxwrCdZZ52eYP/TiWH4g
dg8GCiCm1lgXhoioRB1wve51B8Xi1tfzSxFSO7gfIBLwDjS3oF7OOYd3WqPFDzsi
DgCGHV4dYgWiQV/+bRrO
=qjcy
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
