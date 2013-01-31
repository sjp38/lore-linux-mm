Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id BFD086B0007
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 08:39:07 -0500 (EST)
Message-ID: <1359639529.31386.49.camel@deadeye.wl.decadent.org.uk>
Subject: Re: Bug#695182: [RFC] Reproducible OOM with just a few sleeps
From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 31 Jan 2013 13:38:49 +0000
In-Reply-To: <201301310907.r0V974j9017335@como.maths.usyd.edu.au>
References: <201301310907.r0V974j9017335@como.maths.usyd.edu.au>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+lwp0YMlp66EOvuHrCWf"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au, 695182@bugs.debian.org
Cc: dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@ucw.cz


--=-+lwp0YMlp66EOvuHrCWf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-01-31 at 20:07 +1100, paul.szabo@sydney.edu.au wrote:
> Dear Ben,
>=20
> Thanks for the repeated explanations.
>=20
> > PAE was a stop-gap ...
> > ... [PAE] completely untenable.
>=20
> Is this a good time to withdraw PAE, to tell the world that it does not
> work? Maybe you should have had such comments in the code.
>=20
> Seems that amd64 now works "somewhat": on Debian the linux-image package
> is tricky to install,

If you do an i386 (userland) installation then you must either select
expert mode to get a choice of kernel packages, or else install the
'amd64' kernel package afterward.

> and linux-headers is even harder.

In what way?

> Is there work being done to make this smoother?
[...]

Debian users are now generally installing a full amd64 (userland and
kernel installation.  The default installation image linked from
www.debian.org is the 32/64-bit net-installer which will install amd64
if the system is capable of it.

Based on your experience I might propose to change the automatic kernel
selection for i386 so that we use 'amd64' on a system with >16GB RAM and
a capable processor.

Ben.

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-+lwp0YMlp66EOvuHrCWf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUQpz6ee/yOyVhhEJAQqtKA//ezPwszvsoAa5vbxC40SctisDQcRcoUvg
ify8qz+Ncu6u75VhAq1Pm1dPIrIf3hG6f/o9Oecq3z5BeejRBy3QbBovrI+k9TMq
4X96XtZkf2c5qyNcTZUyC2rsaU/QUZK+qTAZ9UDuWLnrVfIPOLbLxogbb8oA78IB
ztdc+j44jMkm+ZMpzYd+G51glVkzftkDSLV+EKspB4fKDmY/m+v5J/kRdcvd5sEI
VNfH8/u5JLw/wj+/2MhHQuppOltHxn+cI0lGW+QXAkZLoegfxV8JFtKw8ch7lZDr
VqnNrGQ6NJ1g69sFfYySS4ZDmnOfUfj+hXu444JlArz7F1GmBQocvAT5VQktSKAq
t+b7MfMNkf6eSgiQ73Qxk6z4+bgK2FpiBVv0q7JIhOK8GGNxtfGTYHXZmwSGgsiS
jAr7ziMiYNuSDM7BNg4eiCOdgAWC/avxmR45Tbhkz33AH4+YrHQHzX6sHUqe6I7/
KR7dDYny1M5zICtZ/MKNfrRMCY/DvQWqSyG5gDItuBMb21UT6bNxOrPBxezozti6
ZJnWssBWjQQ6YHC/259Raa5oiiCZzTsCZlqdtSruphGTi7x5NRxa79VVCCGrlk8/
rO04AzUOk2Y8WGOefqtxlamKbrCPCnLLgTEwN2Fglb0q5dRrteMnN9NYCAnls0kc
hG6DqhXgBhI=
=aiTr
-----END PGP SIGNATURE-----

--=-+lwp0YMlp66EOvuHrCWf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
