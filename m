Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id DA9F46B0007
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 12:45:57 -0500 (EST)
Message-ID: <1359740732.31386.76.camel@deadeye.wl.decadent.org.uk>
Subject: Re: PAE problems was [RFC] Reproducible OOM with just a few sleeps
From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 01 Feb 2013 18:45:32 +0100
In-Reply-To: <510BF3F1.2050605@zytor.com>
References: <201302010313.r113DTj3027195@como.maths.usyd.edu.au>
	 <510B46C3.5040505@turmel.org> <20130201102044.GA2801@amd.pavel.ucw.cz>
	 <20130201102545.GA3053@amd.pavel.ucw.cz> <510BF3F1.2050605@zytor.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1mM+Wo9zO2OsUpp8Zevh"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Pavel Machek <pavel@denx.de>, Phil Turmel <philip@turmel.org>, paul.szabo@sydney.edu.au, dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--=-1mM+Wo9zO2OsUpp8Zevh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-02-01 at 08:57 -0800, H. Peter Anvin wrote:
[...]
> OK, so by the time this thread gets to me there is of course no=20
> information in it.

Here's the history: http://thread.gmane.org/gmane.linux.kernel.mm/93278

> The vast majority of all 32-bit kernels compiled these days are PAE, so=
=20
> it would seem rather odd if PAE was totally broken.

Indeed.

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-1mM+Wo9zO2OsUpp8Zevh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUQv/POe/yOyVhhEJAQoBPhAA0xEtC12SrmfYxWF0fAZovvL3Lu2936yL
qay12U3nCbhWSuLpCVW2530hxpuYYt/XWtlzIVEQSYm6NpbDb/ZwjK90qRJqS7KW
uETFZyBTlpunRS84i6LoyaIMz479Bnvv31Kv4hHoT+NhPL7gZmtun/COL6fgEGwJ
BCxz/bitt0L2Miw5u1uQr34lpQCzvID42RBgB6xfwyb4RQQ4qk2qdJEN09fkQmdU
tAeYDQQcwPVXko3GtpAUk3liOzC9yo5bcJFZItsRHsUXiUblmFtMBfv3FKuiDXj1
pOe2rHsQ+iL2asxLMfNBaLMEIT/kdQjbFOA199bkp738J75VLveR2jrKMBPmVlia
f+bNAl8RE9X6zHd0oIRKbVb1CehNURoy1Xu/NOT3QsiIfio8KCFJ/VfhWVdZUfNz
0eUvgiX3Pj02jV0dFu+rfw+3UA3qgOJVrfMvUJmgFtt3nfhCE1qu2mBYchM6TQkX
OKYZ9NnC/NLno1BZw+G96X5gvb0Rmsmn71KPLJX3Jbsi2JdsnEK+hfn1wg3kVgAb
siAhwnzH2n1ZhpWVvwFEJmD9o7hQmJl2oEUxMs1DFlegiA4wDuot3869l2tAO3v6
Ce83jBpWbMpBZX/r3pDcRvZj0OgwhRs5g6vcjhNKZS/sa5qopRTMdRYaYBmnw1fU
rZSt6CDtusQ=
=3GSs
-----END PGP SIGNATURE-----

--=-1mM+Wo9zO2OsUpp8Zevh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
