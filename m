Subject: Re: Re: Memory allocation problem
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <20030504194037.12611.qmail@webmail26.rediffmail.com>
References: <20030504194037.12611.qmail@webmail26.rediffmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-RPD+Sx2uaDisNSF3pv06"
Message-Id: <1052123596.1459.2.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: 05 May 2003 10:33:16 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: anand kumar <a_santha@rediffmail.com>
Cc: Mark_H_Johnson@Raytheon.com, kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-RPD+Sx2uaDisNSF3pv06
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2003-05-04 at 21:40, anand kumar wrote:
> Hi,
>=20
> Thanks for immediate response. I used 2.4.20 kernel patched with=20
> bigphys
> area and got it working. I know that this patch is part of Suse
> distribution. Is there any plans to incorporate this patch in=20
> Red Hat?
> Is Red Hat 9 kernel equipped with this patch?

no it's not, nor are there plans to add it. BigPhysArea is a hack, not a
solution. The solution is to use the scatter-gather engine on the pci
card instead of needing to chainsaw physical ram always...

--=-RPD+Sx2uaDisNSF3pv06
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQA+tiHLxULwo51rQBIRAhnaAJ4sxngutUuMnF8W+8z2ANTWHjSTgACcCeCD
5oD4Qk3gnM1Ibs138R230UI=
=3A5v
-----END PGP SIGNATURE-----

--=-RPD+Sx2uaDisNSF3pv06--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
