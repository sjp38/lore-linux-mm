Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BEF596B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 05:30:02 -0400 (EDT)
Date: Mon, 13 Jul 2009 11:51:58 +0200
From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Page allocation failures in guest
Message-ID: <20090713115158.0a4892b0@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-25674-1247478723-0001-2"
Sender: owner-linux-mm@kvack.org
To: avi@redhat.com, kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-25674-1247478723-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

I upgraded my Fedora 10 host to 2.6.29 a few days ago and since then
one of the guests keeps getting page allocation failures after a few
hours. I've upgraded the kernel in the guest from 2.6.27 to 2.6.29
without any change. There are also a few other guests running on the
machine that aren't having any issues.

The only noticable thing that dies for me is the network. The machine
still logs properly and I can attach to the local console and reboot it.

This is what I see in dmesg/logs:

Jul 12 23:04:54 loki kernel: sshd: page allocation failure. order:0, mode:0=
x4020
Jul 12 23:04:54 loki kernel: Pid: 1682, comm: sshd Not tainted 2.6.29.5-84.=
fc10.x86_64 #1
Jul 12 23:04:54 loki kernel: Call Trace:
Jul 12 23:04:54 loki kernel: <IRQ>  [<ffffffff810a1896>] __alloc_pages_inte=
rnal+0x42f/0x451
Jul 12 23:04:54 loki kernel: [<ffffffff810c52f8>] alloc_pages_current+0xb9/=
0xc2
Jul 12 23:04:54 loki kernel: [<ffffffff810c926c>] alloc_slab_page+0x19/0x69
Jul 12 23:04:54 loki kernel: [<ffffffff810c931f>] new_slab+0x63/0x1cb
Jul 12 23:04:54 loki kernel: [<ffffffff810c99fd>] __slab_alloc+0x23d/0x3ac
Jul 12 23:04:54 loki kernel: [<ffffffff812d49f2>] ? __netdev_alloc_skb+0x31=
/0x4d
Jul 12 23:04:54 loki kernel: [<ffffffff810cac1b>] __kmalloc_node_track_call=
er+0xbb/0x11f
Jul 12 23:04:54 loki kernel: [<ffffffff812d49f2>] ? __netdev_alloc_skb+0x31=
/0x4d
Jul 12 23:04:54 loki kernel: [<ffffffff812d3dfc>] __alloc_skb+0x6f/0x130
Jul 12 23:04:54 loki kernel: [<ffffffff812d49f2>] __netdev_alloc_skb+0x31/0=
x4d
Jul 12 23:04:54 loki kernel: [<ffffffffa002e668>] try_fill_recv_maxbufs+0x5=
a/0x20d [virtio_net]
Jul 12 23:04:54 loki kernel: [<ffffffffa002e83d>] try_fill_recv+0x22/0x17e =
[virtio_net]
Jul 12 23:04:54 loki kernel: [<ffffffff812d9c74>] ? netif_receive_skb+0x40a=
/0x42f
Jul 12 23:04:54 loki kernel: [<ffffffffa002f4b9>] virtnet_poll+0x57f/0x5ee =
[virtio_net]
Jul 12 23:04:54 loki kernel: [<ffffffff81374b45>] ? _spin_lock_irq+0x21/0x26
Jul 12 23:04:54 loki kernel: [<ffffffff812d8372>] net_rx_action+0xb3/0x1af
Jul 12 23:04:54 loki kernel: [<ffffffff8104d9f0>] __do_softirq+0x94/0x150
Jul 12 23:04:54 loki kernel: [<ffffffff8101274c>] call_softirq+0x1c/0x30
Jul 12 23:04:54 loki kernel: <EOI>  [<ffffffff81013869>] do_softirq+0x4d/0x=
b4
Jul 12 23:04:54 loki kernel: [<ffffffff812cf149>] ? release_sock+0xb0/0xbb
Jul 12 23:04:54 loki kernel: [<ffffffff8104d86f>] _local_bh_enable_ip+0xc5/=
0xe5
Jul 12 23:04:54 loki kernel: [<ffffffff8104d898>] local_bh_enable_ip+0x9/0xb
Jul 12 23:04:54 loki kernel: [<ffffffff81374954>] _spin_unlock_bh+0x13/0x15
Jul 12 23:04:54 loki kernel: [<ffffffff812cf149>] release_sock+0xb0/0xbb
Jul 12 23:04:54 loki kernel: [<ffffffff812d2f38>] ? __kfree_skb+0x82/0x86
Jul 12 23:04:54 loki kernel: [<ffffffff8130f088>] tcp_recvmsg+0x974/0xa99
Jul 12 23:04:54 loki kernel: [<ffffffff812ce566>] sock_common_recvmsg+0x32/=
0x47
Jul 12 23:04:54 loki kernel: [<ffffffff812cc5a1>] __sock_recvmsg+0x6d/0x7a
Jul 12 23:04:54 loki kernel: [<ffffffff812cc69c>] sock_aio_read+0xee/0xfe
Jul 12 23:04:54 loki kernel: [<ffffffff810d1ecb>] do_sync_read+0xe7/0x12d
Jul 12 23:04:54 loki kernel: [<ffffffff811867ba>] ? rb_erase+0x278/0x2a0
Jul 12 23:04:54 loki kernel: [<ffffffff8105bdc8>] ? autoremove_wake_functio=
n+0x0/0x38
Jul 12 23:04:54 loki kernel: [<ffffffff81374845>] ? _spin_lock+0x9/0xc
Jul 12 23:04:54 loki kernel: [<ffffffff811502e8>] ? security_file_permissio=
n+0x11/0x13
Jul 12 23:04:54 loki kernel: [<ffffffff810d2884>] vfs_read+0xbb/0x102
Jul 12 23:04:54 loki kernel: [<ffffffff810d298f>] sys_read+0x47/0x6e
Jul 12 23:04:54 loki kernel: [<ffffffff8101133a>] system_call_fastpath+0x16=
/0x1b
Jul 12 23:04:54 loki kernel: Mem-Info:
Jul 12 23:04:54 loki kernel: Node 0 DMA per-cpu:
Jul 12 23:04:54 loki kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 12 23:04:54 loki kernel: Node 0 DMA32 per-cpu:
Jul 12 23:04:54 loki kernel: CPU    0: hi:  186, btch:  31 usd: 119
Jul 12 23:04:54 loki kernel: Active_anon:14065 active_file:87384 inactive_a=
non:37480
Jul 12 23:04:54 loki kernel: inactive_file:95821 unevictable:4 dirty:8 writ=
eback:0 unstable:0
Jul 12 23:04:54 loki kernel: free:1344 slab:7113 mapped:4283 pagetables:565=
6 bounce:0
Jul 12 23:04:54 loki kernel: Node 0 DMA free:3988kB min:24kB low:28kB high:=
36kB active_anon:0kB inactive_anon:0kB active_file:3532kB inactive_file:103=
2kB unevictable:0kB present:6840kB pages_scanned:0 all_un
reclaimable? no
Jul 12 23:04:54 loki kernel: lowmem_reserve[]: 0 994 994 994
Jul 12 23:04:54 loki kernel: Node 0 DMA32 free:1388kB min:4020kB low:5024kB=
 high:6028kB active_anon:56260kB inactive_anon:149920kB active_file:346004k=
B inactive_file:382252kB unevictable:16kB present:1018016
kB pages_scanned:96 all_unreclaimable? no
Jul 12 23:04:54 loki kernel: lowmem_reserve[]: 0 0 0 0
Jul 12 23:04:54 loki kernel: Node 0 DMA: 1*4kB 0*8kB 1*16kB 0*32kB 0*64kB 1=
*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB =3D 3988kB
Jul 12 23:04:54 loki kernel: Node 0 DMA32: 4*4kB 77*8kB 3*16kB 0*32kB 1*64k=
B 1*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB =3D 1384kB
Jul 12 23:04:54 loki kernel: 183936 total pagecache pages
Jul 12 23:04:54 loki kernel: 0 pages in swap cache
Jul 12 23:04:54 loki kernel: Swap cache stats: add 0, delete 0, find 0/0
Jul 12 23:04:54 loki kernel: Free swap  =3D 1015800kB
Jul 12 23:04:54 loki kernel: Total swap =3D 1015800kB
Jul 12 23:04:54 loki kernel: 262128 pages RAM
Jul 12 23:04:54 loki kernel: 8339 pages reserved
Jul 12 23:04:54 loki kernel: 34783 pages shared
Jul 12 23:04:54 loki kernel: 245277 pages non-shared

It doesn't look like it's out of memory to me, so I'm not sure what is
going on.

Rgds
--=20
     -- Pierre Ossman

  Linux kernel, MMC maintainer        http://www.kernel.org
  rdesktop, core developer          http://www.rdesktop.org
  TigerVNC, core developer          http://www.tigervnc.org

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.ossman.eu-25674-1247478723-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkpbA8IACgkQ7b8eESbyJLhTagCcD7ff9lGGHwu5TCtbBG0k8Txc
GKkAoODmze/qupVaumUKCbkvD2VMnU6t
=D1jk
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-25674-1247478723-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
