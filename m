Subject: Re: running 2.4.2 kernel under 4MB Ram
From: Arjan van de Ven <arjanv@redhat.com>
In-Reply-To: <1035312869.2209.30.camel@amol.in.ishoni.com>
References: <1035312869.2209.30.camel@amol.in.ishoni.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-qwfqdknSOkEM779OL7f1"
Date: 22 Oct 2002 11:38:34 +0200
Message-Id: <1035279514.3002.0.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Amol Kumar Lad <amolk@ishoni.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-qwfqdknSOkEM779OL7f1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2002-10-22 at 20:54, Amol Kumar Lad wrote:
> Hi,
>  I want to run 2.4.2 kernel on my embedded system that has only 4 Mb
> SDRAM . Is it possible ?? Is there any constraint for the minimum SDRAM
> requirement for linux 2.4.2

2.4.2 was not a good kernel (not unless you patch it to death with 2.4.3
and 2.4.4 stuff) and especially the VM blows chunks. I'd recommend
either using the 2.4.9-ac VM or 2.4.18 with either the -aa or rmap vm
for small machines.


--=-qwfqdknSOkEM779OL7f1
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQA9tRyaxULwo51rQBIRAhcBAJ4l9E+gElu0Y6YZoGZLpLbVbZ1D4QCfezJJ
laDVTy7tciOzu2Rx/EKfDGY=
=UqB7
-----END PGP SIGNATURE-----

--=-qwfqdknSOkEM779OL7f1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
