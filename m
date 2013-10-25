Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C4AD76B00A7
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 06:50:11 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so3784555pdj.38
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 03:50:11 -0700 (PDT)
Received: from psmtp.com ([74.125.245.104])
        by mx.google.com with SMTP id js8si3782065pbc.74.2013.10.25.03.50.09
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 03:50:10 -0700 (PDT)
Date: Fri, 25 Oct 2013 21:49:52 +1100
From: NeilBrown <neilb@suse.de>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
Message-ID: <20131025214952.3eb41201@notabene.brown>
In-Reply-To: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/o0p+.MsNjNOi=r6AgUlpcoW"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, linux-mm@kvack.org

--Sig_/o0p+.MsNjNOi=r6AgUlpcoW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 25 Oct 2013 07:25:13 +0000 (UTC) "Artem S. Tashkinov"
<t.artem@lycos.com> wrote:

> Hello!
>=20
> On my x86-64 PC (Intel Core i5 2500, 16GB RAM), I have the same 3.11 kern=
el
> built for the i686 (with PAE) and x86-64 architectures. What's really tro=
ubling me
> is that the x86-64 kernel has the following problem:
>=20
> When I copy large files to any storage device, be it my HDD with ext4 par=
titions
> or flash drive with FAT32 partitions, the kernel first caches them in mem=
ory entirely
> then flushes them some time later (quite unpredictably though) or immedia=
tely upon
> invoking "sync".
>=20
> How can I disable this memory cache altogether (or at least minimize cach=
ing)? When
> running the i686 kernel with the same configuration I don't observe this =
effect - files get
> written out almost immediately (for instance "sync" takes less than a sec=
ond, whereas
> on x86-64 it can take a dozen of _minutes_ depending on a file size and s=
torage
> performance).

What exactly is bothering you about this?  The amount of memory used or the
time until data is flushed?

If the later, then /proc/sys/vm/dirty_expire_centisecs is where you want to
look.
This defaults to 30 seconds (3000 centisecs).
You could make it smaller (providing you also shrink
dirty_writeback_centisecs in a similar ratio) and the VM will flush out data
more quickly.

NeilBrown


>=20
> I'm _not_ talking about disabling write cache on my storage itself (hdpar=
m -W 0 /dev/XXX)
> - firstly this command is detrimental to the performance of my PC, second=
ly, it won't help
> in this instance.
>=20
> Swap is totally disabled, usually my memory is entirely free.
>=20
> My kernel configuration can be fetched here: https://bugzilla.kernel.org/=
show_bug.cgi?id=3D63531
>=20
> Please, advise.
>=20
> Best regards,
>=20
> Artem=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--Sig_/o0p+.MsNjNOi=r6AgUlpcoW
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmpM0Dnsnt1WYoG5AQKbaA/+I+mILT1c0lnYbOi8ARniGUqmGmgqdPhV
ywBk0r8Tg2G8uk2hL+KGidXAockhIUOMWWazStHfSIS0OCz3PiAH9zJmExP6Qnng
mHsUJbBcaqPnFquUaX+8+zs84Kv4D6RP7hAYaZpkuEDlvrbEXUwnHqKpdEk+RRFv
9bJqEVFHTApcLJ+BHN12UNPRsTXX5Ry10I7IKPJg4col6yZQVWXOvtID7ZrcJt88
IQcLgc6qDVQc6lkKOkrM/5v6oDQy3Ls+VN+6sVvkDtB0s2ZfJeETFNS9JzCWA9N/
8m65S9oCXBIwNyApYdIf/uMMv+RgmmsosqaJ+KiQLkb5AtnsWUtubuD/4gWQZzJK
f6CGinr/ZtzhbhGMq+ogBJ2cOzqbeFGkJlDyGIbNZBrckFRcD80+z0JofTUbQHcN
b7ti4NvZzRYDBdkfSL90HMwlpSg26PExxzMbJryxHYAs85DV9nv/PxK+7nSCBhPI
15zziEoty35885Sd94//ECZIiyZINvhCBH6MEzKPq2o3qwlae0egAZowYcdUlSge
LRAO8NqVQASqNRj9NE+wYAeEyi0ZRX3yK01lWoV7mYyGNz46gMUYtqeC5+q50GLC
dsaQ4preEQHlRsqf8xkYsfZUGTiUa3fWYKiPSXKKIuh2nA8W7IuGDmgdHPj+m1PI
Y2E8MBJave0=
=w1E3
-----END PGP SIGNATURE-----

--Sig_/o0p+.MsNjNOi=r6AgUlpcoW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
