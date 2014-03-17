Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1E46B006E
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 03:08:01 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id x48so4082894wes.24
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 00:08:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j8si4405609wix.20.2014.03.17.00.07.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 00:07:59 -0700 (PDT)
Date: Mon, 17 Mar 2014 18:07:48 +1100
From: NeilBrown <neilb@suse.de>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
Message-ID: <20140317180748.644d30e2@notabene.brown>
In-Reply-To: <20140315101952.GT21483@n2100.arm.linux.org.uk>
References: <20140216200503.GN30257@n2100.arm.linux.org.uk>
	<alpine.DEB.2.02.1402161406120.26926@chino.kir.corp.google.com>
	<20140216225000.GO30257@n2100.arm.linux.org.uk>
	<1392670951.24429.10.camel@sakura.staff.proxad.net>
	<20140217210954.GA21483@n2100.arm.linux.org.uk>
	<20140315101952.GT21483@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/7zuIflDmIm228PLb2DxONT4"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-raid@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Maxime Bizon <mbizon@freebox.fr>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, David Rientjes <rientjes@google.com>

--Sig_/7zuIflDmIm228PLb2DxONT4
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 15 Mar 2014 10:19:52 +0000 Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:

> On Mon, Feb 17, 2014 at 09:09:54PM +0000, Russell King - ARM Linux wrote:
> > On Mon, Feb 17, 2014 at 10:02:31PM +0100, Maxime Bizon wrote:
> > >=20
> > > On Sun, 2014-02-16 at 22:50 +0000, Russell King - ARM Linux wrote:
> > >=20
> > > > http://www.home.arm.linux.org.uk/~rmk/misc/log-20140208.txt
> > >=20
> > > [<c0064ce0>] (__alloc_pages_nodemask+0x0/0x694) from [<c022273c>] (sk=
_page_frag_refill+0x78/0x108)
> > > [<c02226c4>] (sk_page_frag_refill+0x0/0x108) from [<c026a3a4>] (tcp_s=
endmsg+0x654/0xd1c)  r6:00000520 r5:c277bae0 r4:c68f37c0
> > > [<c0269d50>] (tcp_sendmsg+0x0/0xd1c) from [<c028ca9c>] (inet_sendmsg+=
0x64/0x70)
> > >=20
> > > FWIW I had OOMs with the exact same backtrace on kirkwood platform
> > > (512MB RAM), but sorry I don't have the full dump anymore.
> > >=20
> > > I found a slow leaking process, and since I fixed that leak I now have
> > > uptime better than 7 days, *but* there was definitely some memory left
> > > when the OOM happened, so it appears to be related to fragmentation.
> >=20
> > However, that's a side effect, not the cause - and a patch has been
> > merged to fix that OOM - but that doesn't explain where most of the
> > memory has gone!
> >=20
> > I'm presently waiting for the machine to OOM again (it's probably going
> > to be something like another month) at which point I'll grab the files
> > people have been mentioning (/proc/meminfo, /proc/vmallocinfo,
> > /proc/slabinfo etc.)
>=20
> For those new to this report, this is a 3.12.6+ kernel, and I'm seeing
> OOMs after a month or two of uptime.
>=20
> Last night, it OOM'd severely again at around 5am... and rebooted soon
> after so we've lost any hope of recovering anything useful from the
> machine.
>=20
> However, the new kernel re-ran the raid check, and...
>=20
> md: data-check of RAID array md2
> md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
> md: using maximum available idle IO bandwidth (but not more than 200000 K=
B/sec)
> for data-check.
> md: using 128k window, over a total of 4194688k.
> md: delaying data-check of md3 until md2 has finished (they share one or =
more physical units)
> md: delaying data-check of md4 until md2 has finished (they share one or =
more physical units)
> md: delaying data-check of md3 until md2 has finished (they share one or =
more physical units)
> md: delaying data-check of md5 until md2 has finished (they share one or =
more physical units)
> md: delaying data-check of md3 until md2 has finished (they share one or =
more physical units)
> md: delaying data-check of md4 until md2 has finished (they share one or =
more physical units)
> md: delaying data-check of md6 until md2 has finished (they share one or =
more physical units)
> md: delaying data-check of md4 until md2 has finished (they share one or =
more physical units)
> md: delaying data-check of md3 until md2 has finished (they share one or =
more physical units)
> md: delaying data-check of md5 until md2 has finished (they share one or =
more physical units)
> md: md2: data-check done.
> md: delaying data-check of md5 until md3 has finished (they share one or =
more physical units)
> md: data-check of RAID array md3
> md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
> md: using maximum available idle IO bandwidth (but not more than 200000 K=
B/sec)
> for data-check.
> md: using 128k window, over a total of 524544k.
> md: delaying data-check of md4 until md3 has finished (they share one or =
more physical units)
> md: delaying data-check of md6 until md3 has finished (they share one or =
more physical units)
> kmemleak: 836 new suspected memory leaks (see /sys/kernel/debug/kmemleak)
> md: md3: data-check done.
> md: delaying data-check of md6 until md4 has finished (they share one or =
more physical units)
> md: delaying data-check of md4 until md5 has finished (they share one or =
more physical units)
> md: data-check of RAID array md5
> md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
> md: using maximum available idle IO bandwidth (but not more than 200000 K=
B/sec)
> for data-check.
> md: using 128k window, over a total of 10486080k.
> kmemleak: 2235 new suspected memory leaks (see /sys/kernel/debug/kmemleak)
> md: md5: data-check done.
> md: data-check of RAID array md4
> md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
> md: using maximum available idle IO bandwidth (but not more than 200000 K=
B/sec)
> for data-check.
> md: using 128k window, over a total of 10486080k.
> md: delaying data-check of md6 until md4 has finished (they share one or =
more physical units)
> kmemleak: 1 new suspected memory leaks (see /sys/kernel/debug/kmemleak)
> md: md4: data-check done.
> md: data-check of RAID array md6
> md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
> md: using maximum available idle IO bandwidth (but not more than 200000 K=
B/sec)
> for data-check.
> md: using 128k window, over a total of 10409472k.
> kmemleak: 1 new suspected memory leaks (see /sys/kernel/debug/kmemleak)
> kmemleak: 3 new suspected memory leaks (see /sys/kernel/debug/kmemleak)
> md: md6: data-check done.
> kmemleak: 1 new suspected memory leaks (see /sys/kernel/debug/kmemleak)
>=20
> which totals 3077 of leaks.  So we have a memory leak.  Looking at
> the kmemleak file:
>=20
> unreferenced object 0xc3c3f880 (size 256):
>   comm "md2_resync", pid 4680, jiffies 638245 (age 8615.570s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 f0  ................
>     00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<c008d4f0>] __save_stack_trace+0x34/0x40
>     [<c008d5f0>] create_object+0xf4/0x214
>     [<c02da114>] kmemleak_alloc+0x3c/0x6c
>     [<c008c0d4>] __kmalloc+0xd0/0x124
>     [<c00bb124>] bio_alloc_bioset+0x4c/0x1a4
>     [<c021206c>] r1buf_pool_alloc+0x40/0x148
>     [<c0061160>] mempool_alloc+0x54/0xfc
>     [<c0211938>] sync_request+0x168/0x85c
>     [<c021addc>] md_do_sync+0x75c/0xbc0
>     [<c021b594>] md_thread+0x138/0x154
>     [<c0037b48>] kthread+0xb0/0xbc
>     [<c0013190>] ret_from_fork+0x14/0x24
>     [<ffffffff>] 0xffffffff
>=20
> with 3077 of these in the debug file.  3075 are for "md2_resync" and
> two are for "md4_resync".
>=20
> /proc/slabinfo shows for this bucket:
> kmalloc-256         3237   3450    256   15    1 : tunables  120   60    =
0 : slabdata    230    230      0
>=20
> but this would only account for about 800kB of memory usage, which itself
> is insignificant - so this is not the whole story.
>=20
> It seems that this is the culpret for the allocations:
>         for (j =3D pi->raid_disks ; j-- ; ) {
>                 bio =3D bio_kmalloc(gfp_flags, RESYNC_PAGES);
>=20
> Since RESYNC_PAGES will be 64K/4K=3D16, each struct bio_vec is 12 bytes
> (12 * 16 =3D 192) plus the size of struct bio, which would fall into this
> bucket.
>=20
> I don't see anything obvious - it looks like it isn't every raid check
> which loses bios.  Not quite sure what to make of this right now.
>=20

I can't see anything obvious either.

The bios allocated there are stored in a r1_bio and those pointers are never
changed.
If the r1_bio wasn't freed then when the data-check finished, mempool_destr=
oy
would complain that the pool wasn't completely freed.
And when the r1_bio is freed, all the bios are put as well.

I guess if something was calling bio_get() on the bio, then might stop the
bio_put from freeing the memory, but I cannot see anything that would do th=
at.

I've tried testing on a recent mainline kernel and while kmemleak shows abo=
ut
238 leaks from "swapper/0", there are none related to md or bios.

I'll let it run a while longer and see if anything pops.

NeilBrown

--Sig_/7zuIflDmIm228PLb2DxONT4
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUyafRDnsnt1WYoG5AQLoLBAAhJ1mFPGUH+ZvK+9aZ+tQfPDsN0gDeXA7
RE/MOsY33e9TWeYBi35p8UbzqlESmMI4v4kLyjnknzUQSKQpI66YC3jchwk+bi29
8T6e044IhnKf0V25aVJSu3Xyk4EyAWrm1TYz/rf7gFMwoG7DBtWxpKaOiVCTSAkM
XuQTXViUM3BfmSoGduU7V5QM4NuHQY1zCLTfb0/VpA4tMRosoozXeL1bLKjwHp9n
eHBBuhz7fgO+ZeMIR5WqF6IPx4JoG1Y/sLamBud+lBTTRjATrCXqjxfnke00glzl
MEReE3qke0w7u3ckG83QpCivrM8ErLArweid1u9OC1O9vnDX/W+gYmhVdlQh8+Sf
rqmmQePqvjzLClEou6YR10KntMRDm8ujSrEXHWJc1t1wI/VDgm398DmkhcPWTEx0
j2kLv4e6L+8Y8Rf5FCwlbsMz2ujXtwSatLFqguCcn2SnS/spnxM76QMPhMhM0z6s
E7Cl0XdrXoLCxFNY6Nd0xnRYt8ORzvdVjh3WuQb39+CFriLeMtmbudpkEAo4e5Qv
ntmU1nU/b0+In8PTo6vM0vHbF1eLCREaKS9UOlbJyEmvB91N/tib2bu4gqz1aaCX
JJJIS58f8cjFpsdrHnZ1NWXgVzE2KACPoWfMmTuXOITHLkZgeXce4Y+OcRmjXBQY
m56dIlTgNCE=
=F4dk
-----END PGP SIGNATURE-----

--Sig_/7zuIflDmIm228PLb2DxONT4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
