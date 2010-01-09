Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 918F56B006A
	for <linux-mm@kvack.org>; Sat,  9 Jan 2010 16:32:29 -0500 (EST)
From: Michail Bachmann <mb@emeraldcity.de>
Subject: PROBLEM: kernel BUG at mm/page_alloc.c:775
Date: Sat, 9 Jan 2010 22:32:10 +0100
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1272288.ZqYSMc2O7a";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201001092232.21841.mb@emeraldcity.de>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--nextPart1272288.ZqYSMc2O7a
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

When starting the system with a kernel version of 2.6.31 or later (I tested=
 it=20
from 2.6.31.1 up to 2.6.33-rc3) after a while the kernel will panic with th=
e=20
following message (from2.6.32.2) :

[   48.505381] kernel BUG at mm/page_alloc.c:775!
[   48.505467] invalid opcode: 0000 [#1]=20
[   48.505589] last sysfs file:=20
[   48.505672] Modules linked in:
[   48.505788]=20
[   48.505870] Pid: 343, comm: fsck.ext3 Not tainted (2.6.32.2-200912310108=
=20
#1) System Name
[   48.505994] EIP: 0060:[<c01641c6>] EFLAGS: 00010093 CPU: 0
[   48.506094] EIP is at move_freepages_block+0x86/0x130
[   48.506178] EAX: 000002fc EBX: 00000040 ECX: 00000000 EDX: 00000001
[   48.506264] ESI: 000041ed EDI: c1368000 EBP: e7267c70 ESP: e7267c50
[   48.506350]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[   48.506438] Process fsck.ext3 (pid: 343, ti=3De7266000 task=3De7b78720=20
task.ti=3De7266000)
[   48.506558] Stack:
[   48.506634]  00000000 00000000 c042595c c136ffe0 e7267c78 c1368018 00000=
002=20
000001b8
[   48.506974] <0> e7267cc0 c0164751 00000000 c03fd58c 00000001=20
c0361780e7267ca8 00000206
[   48.507379] <0> 00000000 00000000 c042595c c1368000 00011210=20
c0425b50c0425b50 c0425998
[   48.507855] Call Trace:
[   48.507938]  [<c0164751>] ? __rmqueue+0x1a1/0x350
[   48.508027]  [<c016636b>] ? get_page_from_freelist+0x35b/0x420
[   48.508115]  [<c01664f8>] ? __alloc_pages_nodemask+0xc8/0x510
[   48.508215]  [<c011db73>] ? dequeue_task+0x63/0xb0
[   48.508304]  [<c0167ea8>] ? __do_page_cache_readahead+0xb8/0x1b0
[   48.508396]  [<c0167fc8>] ? ra_submit+0x28/0x30
[   48.508480]  [<c01681cd>] ? ondemand_readahead+0xfd/0x1e0
[   48.508567]  [<c0168320>] ? page_cache_async_readahead+0x70/0x90
[   48.508653]  [<c0162c8c>] ? generic_file_aio_read+0x2fc/0x620
[   48.508741]  [<c018b101>] ? do_sync_read+0xd1/0x110
[   48.508834]  [<c01369f0>] ? autoremove_wake_function+0x0/0x40
[   48.508928]  [<c0284c20>] ? n_tty_write+0x0/0x3d0
[   48.509018]  [<c02402ff>] ? security_file_permission+0xf/0x20
[   48.509103]  [<c018b194>] ? rw_verify_area+0x54/0xd0
[   48.509188]  [<c018bd39>] ? vfs_read+0x99/0x160
[   48.509269]  [<c018b030>] ? do_sync_read+0x0/0x110
[   48.509351]  [<c018bebd>] ? sys_read+0x3d/0x70
[   48.509434]  [<c0102c44>] ? sysenter_do_call+0x12/0x22
[   48.509517] Code: c1 e2 06 c1 e1 08 29 d1 8b 93 e0 7f 00 00 29 c1 c1 e1 =
02=20
c1 ea 1e 89 d3 89 d0 c1 e3 06 c1 e0 08 29 d8 29 d0 c1 e0 02 39 c1 74 1c <0f=
>=20
0b eb fe 8d b6 00 00 00 00 c7 45 f0 00 00 00 00 8b 45 f0 83=20
[   48.511798] EIP: [<c01641c6>] move_freepages_block+0x86/0x130 SS:ESP=20
0068:e7267c50
[   48.511990] ---[ end trace 45c7d49cba718751 ]---

My memory layout on this box is (from dmesg):

=2D---
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  Normal   0x00001000 -> 0x00027fec
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000000 -> 0x00000001
    0: 0x00000010 -> 0x000000a0
    0: 0x00000100 -> 0x00027fec
On node 0 totalpages: 163709
free_area_init_node: node 0, pgdat c0425660, node_mem_map c1000000
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 3953 pages, LIFO batch:0
  Normal zone: 1248 pages used for memmap
  Normal zone: 158476 pages, LIFO batch:31
=2D---

The last kernel version without this problem seems to be the 2.6.30.x (I am=
=20
running 2.6.30.10 right now without any problems).

If you need any more information from my system don't hesitate to ask.

CU Micha

--nextPart1272288.ZqYSMc2O7a
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCAAGBQJLSPXeAAoJEDOFMLjtzdvOGmwQAKSpOix7nOzOnMxkOoG5JYOn
wfLla+APr4Mp+kS1pFgpeSiGrKU1WYL7iVbMZ9Oz0JcViUTiZnHZR3h7LglTeL59
CHDBHZVs/RioZGRUzNtJa4PWVW3qmV3PGM6jFGhpIACBT49b/Glt6zAJ/NQ7IvKB
b8Sx7yep/k0V6vxvYhvqD7LcOLz81XTv3yrErYmCbIXpD1nlLk0RixNDAsqzUwJl
462h+mg8/UE8dl9Hpnnw460IsM2S3qAN8ZjbIWysIN2p2oPhUMfeLQ1ja164Bhhb
yGWEHtqYkr54qZxHkTBZBw+HE3HQMEp2gC8ZF5HyD/aPdNF98JF44BYnFxaTz3T9
h6E5+FLKBE/FhXEpd2c7S9SAb6fyQezqEyv5DPvZsWGfj730OYKSqDaOEKctJ47c
wTiEoZF/8fYMrNfZY9nbVXixuJ5ltEa0VUvF3rhg2jO9pH8b4b4fv7e+pM9GNSfY
pwF+a/WhU06m1fKkZDp8wdTbu4irGDw/BNZutpporpt+rT0IkuG9iYWEmpzOoDSC
yCRizUb/aXXzZnOyHZCPox/re/VEEpXqXaMNtycaH9q2LW+ZB1oI4Pb3obAngw9T
j1yB6/g1LKm50RdD0HqqRdy2Y9SnM2+a32I+ImD/4Flg7/mkbr9M/0faptyiAh3G
Ic9bboOPNduHsiimhC9+
=eXs0
-----END PGP SIGNATURE-----

--nextPart1272288.ZqYSMc2O7a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
