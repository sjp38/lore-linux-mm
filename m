Subject: Re: [PATCH] dirty bit clearing on s390.
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <20030522112000.GA2597@mschwid3.boeblingen.de.ibm.com>
References: <20030522112000.GA2597@mschwid3.boeblingen.de.ibm.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-eIYQvzJ2RzM2EzY3iBVw"
Message-Id: <1053603729.2360.0.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: 22 May 2003 13:42:09 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, akpm@digeo.com, phillips@arcor.de
List-ID: <linux-mm.kvack.org>

--=-eIYQvzJ2RzM2EzY3iBVw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2003-05-22 at 13:20, Martin Schwidefsky wrote:


> Our solution is to move the clearing of the storage key (dirty bit)
> from set_pte to SetPageUptodate. A patch that implements this is
> attached. What do you think ?

Is there anything that prevents a thread mmaping the page to redirty it
before the kernel marks it uptodate ?=20

--=-eIYQvzJ2RzM2EzY3iBVw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA+zLeRxULwo51rQBIRAnkRAJ4sYlnnpkkR1USZP5T1WrFCM3tquwCfc3FN
qjXVRtN9xqsZXMvxNN3Bias=
=Leyg
-----END PGP SIGNATURE-----

--=-eIYQvzJ2RzM2EzY3iBVw--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
