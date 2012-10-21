Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 1B16B6B0069
	for <linux-mm@kvack.org>; Sun, 21 Oct 2012 14:43:44 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id p5so1418465lag.14
        for <linux-mm@kvack.org>; Sun, 21 Oct 2012 11:43:42 -0700 (PDT)
Date: Mon, 22 Oct 2012 00:43:32 +0600
From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
Message-ID: <20121022004332.7e3f3f29@sacrilege>
In-Reply-To: <20121021195701.7a5872e7@sacrilege>
References: <20121019205055.2b258d09@sacrilege>
	<20121019233632.26cf96d8@sacrilege>
	<CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
	<20121020204958.4bc8e293@sacrilege>
	<20121021044540.12e8f4b7@sacrilege>
	<20121021062402.7c4c4cb8@sacrilege>
	<1350826183.13333.2243.camel@edumazet-glaptop>
	<20121021195701.7a5872e7@sacrilege>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/H32pOVATOpST__ZRjbR3yuQ"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org, linux-mm@kvack.org

--Sig_/H32pOVATOpST__ZRjbR3yuQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 21 Oct 2012 19:57:01 +0600
Mike Kazantsev <mk.fraggod@gmail.com> wrote:

> On Sun, 21 Oct 2012 15:29:43 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> >=20
> > Did you try linux-3.7-rc2 (or linux-3.7-rc1) ?
> >=20
>=20
> I did not, will do in a few hours, thanks for the pointer.
>=20

I just built "torvalds/linux-2.6" (v3.7-rc2) and rebooted into it,
started same rsync-over-net test and got kmalloc-64 leaking (it went up
to tens of MiB until I stopped rsync, normally these are fixed at ~500
KiB).

Unfortunately, I forgot to add slub_debug option and build kmemleak so
wasn't able to look at this case further, and when I rebooted with
these enabled/built, it was secpath_cache again.

So previously noted "slabtop showed 'kmalloc-64' being the 99% offender
in the past, but with recent kernels (3.6.1), it has changed to
'secpath_cache'" seem to be incorrect, as it seem to depend not on
kernel version, but some other factor.

Guess I'll try to reboot a few more times to see if I can catch
kmalloc-64 leaking (instead of secpath_cache) again.


--=20
Mike Kazantsev // fraggod.net

--Sig_/H32pOVATOpST__ZRjbR3yuQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCEQlcACgkQASbOZpzyXnHh8gCg4l+nCAOyqwG3ew1jufeHSKxd
BpkAoK0lWwI6K6xgrG03vnJ/9gNammaI
=Fkg7
-----END PGP SIGNATURE-----

--Sig_/H32pOVATOpST__ZRjbR3yuQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
