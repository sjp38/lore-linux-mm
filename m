Subject: Re: Trouble freeing pinned pages.
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <20040429122741.95537.qmail@web21407.mail.yahoo.com>
References: <20040429122741.95537.qmail@web21407.mail.yahoo.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-uJahnzm/LQo9k7uI9d1z"
Message-Id: <1083250281.4634.18.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: Thu, 29 Apr 2004 16:51:21 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mahesh gowda <aryamithra@yahoo.com>
Cc: Linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-uJahnzm/LQo9k7uI9d1z
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-04-29 at 14:27, mahesh gowda wrote:
> We are developing a device driver on kernel version
> 2.4.21. We have a program in user-space that registers
>=20
> a part of its virtual address space with our driver.
> This memory may be anonymous or file backed.


that sounds broken. But do you have a URL to your driver so that we can
have suggestions on how to fix it ?

--=-uJahnzm/LQo9k7uI9d1z
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBAkRZpxULwo51rQBIRApr5AJ9imerXEm7R0nDNhK0D+RPj7foaTACfVm0T
ZkmGz4krdY51YzERZzavHfg=
=tybi
-----END PGP SIGNATURE-----

--=-uJahnzm/LQo9k7uI9d1z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
