Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C62946B008C
	for <linux-mm@kvack.org>; Sat,  7 Mar 2009 16:01:06 -0500 (EST)
Date: Sat, 7 Mar 2009 22:00:55 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090307220055.6f79beb8@mjolnir.ossman.eu>
In-Reply-To: <20090307122452.bf43fbe4.akpm@linux-foundation.org>
References: <bug-12832-27@http.bugzilla.kernel.org/>
	<20090307122452.bf43fbe4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-3302-1236459659-0001-2"
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-3302-1236459659-0001-2
Content-Type: multipart/mixed; boundary="MP_/6P0XGjJoJYinpSZBWBmVmc1"

--MP_/6P0XGjJoJYinpSZBWBmVmc1
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sat, 7 Mar 2009 12:24:52 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

>=20
> hm, not a lot to go on there.
>=20
> We have quite a lot of instrumentation for memory consumption - were
> you able to work out where it went by comparing /proc/meminfo,
> /proc/slabinfo, `echo m > /proc/sysrq-trigger', etc?
>=20

The redhat entry contains all the info, and I've compared meminfo and
slabinfo without finding anything even close to the chunks of lost
memory.

I've attached the sysrq memory stats from 2.6.26 and 2.6.27. The only
difference though is in the reported free pages

I'm not very familiar with all the instrumentation, so pointers are
very welcome.

> Is the memory missing on initial boot up, or does it take some time for
> the problem to become evident?
>=20

Initial boot as far as I can tell.


Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--MP_/6P0XGjJoJYinpSZBWBmVmc1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=mem-2.6.26.txt

Linux builder.drzeus.cx 2.6.26.6-79.fc9.x86_64 #1 SMP Fri Oct 17 14:20:33 E=
DT 2008 x86_64 x86_64 x86_64 GNU/Linux
SysRq : Show Memory
Mem-info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 115
Active:8937 inactive:6285 dirty:48 writeback:0 unstable:0
 free:103730 slab:5612 mapped:2148 pagetables:817 bounce:0
Node 0 DMA free:10292kB min:48kB low:60kB high:72kB active:0kB inactive:0kB=
 present:8908kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 489 489 489
Node 0 DMA32 free:404628kB min:2804kB low:3504kB high:4204kB active:35748kB=
 inactive:25140kB present:500896kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 3*4kB 5*8kB 4*16kB 4*32kB 3*64kB 3*128kB 3*256kB 3*512kB 3*1024=
kB 2*2048kB 0*4096kB =3D 10292kB
Node 0 DMA32: 3*4kB 5*8kB 2*16kB 2*32kB 2*64kB 1*128kB 3*256kB 2*512kB 3*10=
24kB 3*2048kB 96*4096kB =3D 404628kB
9730 total pagecache pages
Swap cache: add 0, delete 0, find 0/0
Free swap  =3D 524280kB
Total swap =3D 524280kB
131056 pages of RAM
3772 reserved pages
7750 pages shared
0 pages swap cached


--MP_/6P0XGjJoJYinpSZBWBmVmc1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=mem-2.6.27.txt

Linux builder.drzeus.cx 2.6.27.4-19.fc9.x86_64 #1 SMP Thu Oct 30 19:30:01 E=
DT 2008 x86_64 x86_64 x86_64 GNU/Linux
SysRq : Show Memory
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  86
Active:8879 inactive:6265 dirty:8 writeback:0 unstable:0
 free:62265 slab:5543 mapped:2154 pagetables:821 bounce:0
Node 0 DMA free:9448kB min:40kB low:48kB high:60kB active:0kB inactive:0kB =
present:7804kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 489 489 489
Node 0 DMA32 free:239612kB min:2808kB low:3508kB high:4212kB active:35516kB=
 inactive:25060kB present:500896kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 4*4kB 3*8kB 2*16kB 5*32kB 4*64kB 2*128kB 2*256kB 2*512kB 3*1024=
kB 2*2048kB 0*4096kB =3D 9448kB
Node 0 DMA32: 1*4kB 7*8kB 6*16kB 1*32kB 1*64kB 4*128kB 3*256kB 3*512kB 1*10=
24kB 3*2048kB 56*4096kB =3D 239612kB
9692 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  =3D 524280kB
Total swap =3D 524280kB
131056 pages RAM
4046 pages reserved
7770 pages shared
61196 pages non-shared


--MP_/6P0XGjJoJYinpSZBWBmVmc1--

--=_freyr.drzeus.cx-3302-1236459659-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkmy4IoACgkQ7b8eESbyJLja0wCg5LIPyWCG7sm+OaIR0wGAOi/x
wFkAn0nigt4XwbMDUFH3Qq42kyw9dGXk
=pDk5
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-3302-1236459659-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
