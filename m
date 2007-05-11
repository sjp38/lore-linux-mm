Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2,
	mode:0x84020
From: Nicolas Mailhot <nicolas.mailhot@laposte.net>
In-Reply-To: <20070511173811.GA8529@skynet.ie>
References: <Pine.LNX.4.64.0705101510500.13404@schroedinger.engr.sgi.com>
	 <20070510221607.GA15084@skynet.ie>
	 <Pine.LNX.4.64.0705101522250.13504@schroedinger.engr.sgi.com>
	 <20070510224441.GA15332@skynet.ie>
	 <Pine.LNX.4.64.0705101547020.14064@schroedinger.engr.sgi.com>
	 <20070510230044.GB15332@skynet.ie>
	 <Pine.LNX.4.64.0705101601220.14471@schroedinger.engr.sgi.com>
	 <1178863002.24635.4.camel@rousalka.dyndns.org>
	 <20070511090823.GA29273@skynet.ie>
	 <1178884283.27195.1.camel@rousalka.dyndns.org>
	 <20070511173811.GA8529@skynet.ie>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-T2tXx3uEIgOY/U4JxrYw"
Date: Fri, 11 May 2007 19:45:41 +0200
Message-Id: <1178905541.2473.2.camel@rousalka.dyndns.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-T2tXx3uEIgOY/U4JxrYw
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Le vendredi 11 mai 2007 =C3=A0 18:38 +0100, Mel Gorman a =C3=A9crit :
> On (11/05/07 13:51), Nicolas Mailhot didst pronounce:
> > Le vendredi 11 mai 2007 =C3=A0 10:08 +0100, Mel Gorman a =C3=A9crit :
> >=20
> > > > seems to have cured the system so far (need to charge it a bit long=
er to
> > > > be sure)
> > > >=20
> > >=20
> > > The longer it runs the better, particularly under load and after
> > > updatedb has run. Thanks a lot for testing
> >=20
> > After a few hours of load testing still nothing in the logs, so the
> > revert was probably the right thing to do
>=20
> Excellent. I am somewhat suprised by the result=20

And you're probably right, it just banged after a day working fine

19:20:00  tar: page allocation failure. order:2, mode:0x84020
19:20:00 =20
19:20:00  Call Trace:
19:20:00  [<ffffffff8025b5c3>] __alloc_pages+0x2aa/0x2c3
19:20:00  [<ffffffff802751f5>] __slab_alloc+0x196/0x586
19:20:00  [<ffffffff80300d79>] radix_tree_node_alloc+0x36/0x7e
19:20:00  [<ffffffff8027597a>] kmem_cache_alloc+0x32/0x4e
19:20:00  [<ffffffff80300d79>] radix_tree_node_alloc+0x36/0x7e
19:20:00  [<ffffffff8030118e>] radix_tree_insert+0x5d/0x18c
19:20:00  [<ffffffff80256ac4>] add_to_page_cache+0x3d/0x95
19:20:00  [<ffffffff80257aa4>] generic_file_buffered_write+0x222/0x7c8
19:20:00  [<ffffffff88013c74>] :jbd:do_get_write_access+0x506/0x53d
19:20:00  [<ffffffff8022c7d5>] current_fs_time+0x3b/0x40
19:20:00  [<ffffffff8025838c>] __generic_file_aio_write_nolock+0x342/0x3ac
19:20:00  [<ffffffff80416ac1>] __mutex_lock_slowpath+0x216/0x221
19:20:00  [<ffffffff80258457>] generic_file_aio_write+0x61/0xc1
19:20:00  [<ffffffff880271be>] :ext3:ext3_file_write+0x16/0x94
19:20:00  [<ffffffff8027938c>] do_sync_write+0xc9/0x10c
19:20:00  [<ffffffff80239c56>] autoremove_wake_function+0x0/0x2e
19:20:00  [<ffffffff80279ba7>] vfs_write+0xce/0x177
19:20:00  [<ffffffff8027a16a>] sys_write+0x45/0x6e
19:20:00  [<ffffffff8020955c>] tracesys+0xdc/0xe1
19:20:00 =20
19:20:00  Mem-info:
19:20:00  DMA per-cpu:
19:20:00  CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btc=
h:   1 usd:   0
19:20:00  CPU    1: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btc=
h:   1 usd:   0
19:20:00  DMA32 per-cpu:
19:20:00  CPU    0: Hot: hi:  186, btch:  31 usd: 149   Cold: hi:   62, btc=
h:  15 usd:  19
19:20:00  CPU    1: Hot: hi:  186, btch:  31 usd: 147   Cold: hi:   62, btc=
h:  15 usd:   2
19:20:00  Active:348968 inactive:105561 dirty:23054 writeback:0 unstable:0
19:20:00  free:9776 slab:28092 mapped:23015 pagetables:10226 bounce:0
19:20:00  DMA free:7960kB min:20kB low:24kB high:28kB active:0kB inactive:0=
kB present:7648kB pages_scanned:0 all_unreclaimable? yes
19:20:00  lowmem_reserve[]: 0 1988 1988 1988
19:20:00  DMA32 free:31144kB min:5692kB low:7112kB high:8536kB active:13958=
72kB inactive:422244kB present:2036004kB pages_scanned:0 all_unreclaimable?=
 no
19:20:00  lowmem_reserve[]: 0 0 0 0
19:20:00  DMA: 6*4kB 6*8kB 7*16kB 3*32kB 8*64kB 8*128kB 6*256kB 1*512kB 0*1=
024kB 0*2048kB 1*4096kB =3D 7960kB
19:20:00  DMA32: 7560*4kB 0*8kB 8*16kB 0*32kB 1*64kB 1*128kB 0*256kB 1*512k=
B 0*1024kB 0*2048kB 0*4096kB =3D 31072kB
19:20:00  Swap cache: add 1527, delete 1521, find 216/286, race 397+0
19:20:00  Free swap  =3D 4192824kB
19:20:00  Total swap =3D 4192944kB
19:20:00  Free swap:       4192824kB
19:20:00  524272 pages of RAM
19:20:00  14123 reserved pages
19:20:00  252562 pages shared
19:20:00  6 pages swap cached

> so I'd like to look at the
> alternative option with kswapd as well. Could you put that patch back in =
again
> please and try the following patch instead?=20

I'll try this one now (if it applies)

Regards,

--=20
Nicolas Mailhot

--=-T2tXx3uEIgOY/U4JxrYw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Ceci est une partie de message
	=?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iEYEABECAAYFAkZEq78ACgkQI2bVKDsp8g099gCg6M451SghKniJ7fdWGOxbp/2J
bygAoJ1Xkn3TC75ragCFIwza9AZtt1bk
=N5J0
-----END PGP SIGNATURE-----

--=-T2tXx3uEIgOY/U4JxrYw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
