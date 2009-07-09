Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 44B056B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 06:38:22 -0400 (EDT)
Date: Thu, 9 Jul 2009 13:55:49 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemeleak BUG: lock held when returning to user space!
Message-ID: <20090709105549.GB3434@localdomain.by>
References: <20090709104202.GA3434@localdomain.by>
 <tnxeisquo90.fsf@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BwCQnh7xodEAoBMC"
Content-Disposition: inline
In-Reply-To: <tnxeisquo90.fsf@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--BwCQnh7xodEAoBMC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On (07/09/09 11:47), Catalin Marinas wrote:
> Date: Thu, 09 Jul 2009 11:47:23 +0100
> From: Catalin Marinas <catalin.marinas@arm.com>
> To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
> 	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
> 	linux-kernel@vger.kernel.org, linux-mm@kvack.org
> Subject: Re: kmemeleak BUG: lock held when returning to user space!
> User-Agent: Gnus/5.11 (Gnus v5.11) Emacs/22.1 (gnu/linux)
>=20
> Sergey Senozhatsky <sergey.senozhatsky@mail.by> wrote:
> > kernel: [  149.507103] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
> > kernel: [  149.507113] [ BUG: lock held when returning to user space! ]
> > kernel: [  149.507119] ------------------------------------------------
> > kernel: [  149.507127] cat/3279 is leaving the kernel with locks still =
held!
> > kernel: [  149.507135] 1 lock held by cat/3279:
> > kernel: [  149.507141]  #0:  (scan_mutex){+.+.+.}, at: [<c110707c>] kme=
mleak_open+0x4c/0x80
> >
> > problem is here:
> > static int kmemleak_open(struct inode *inode, struct file *file)
>=20
> It's been fixed in my kmemleak branch which I'll push to Linus:
>=20
Ok. Nice to hear.

> http://www.linux-arm.org/git?p=3Dlinux-2.6.git;a=3Dshortlog;h=3Dkmemleak
>=20
> --=20
> Catalin
>=20

	Sergey
--BwCQnh7xodEAoBMC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iJwEAQECAAYFAkpVzLUACgkQfKHnntdSXjTpQwQA1EX6uQ7i38G8BWSaWAOzltDW
G7Kat5fxYMQGt8/fswOF0ODBEa6a8fm2ThIWkIRpUIN/MFDE7j3OMAfw8pfvwpDt
p55fvdbG82nR4Nw4MW7JIsldTRF0/s2Vf9+8HJ921IiBoFgh3yexpHC8UBAqYZ6f
mRzNxn2itpIxsCDSZBk=
=2xyK
-----END PGP SIGNATURE-----

--BwCQnh7xodEAoBMC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
