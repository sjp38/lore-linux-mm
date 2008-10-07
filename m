Received: by ik-out-1112.google.com with SMTP id c21so2336146ika.6
        for <linux-mm@kvack.org>; Tue, 07 Oct 2008 03:07:55 -0700 (PDT)
Date: Tue, 7 Oct 2008 13:09:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC, v2] shmat: introduce flag SHM_MAP_HINT
Message-ID: <20081007100854.GA5039@localhost.localdomain>
References: <20081006192923.GJ3180@one.firstfloor.org> <1223362670-5187-1-git-send-email-kirill@shutemov.name> <20081007082030.GD20740@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pf9I7BMVVzbSWLtt"
Content-Disposition: inline
In-Reply-To: <20081007082030.GD20740@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 07, 2008 at 10:20:30AM +0200, Andi Kleen wrote:
> On Tue, Oct 07, 2008 at 09:57:50AM +0300, Kirill A. Shutemov wrote:
> > It allows interpret attach address as a hint, not as exact address.
>=20
> Please expand the description a bit. Rationale. etc.
>=20
> > @@ -55,6 +55,7 @@ struct shmid_ds {
> >  #define	SHM_RND		020000	/* round attach address to SHMLBA boundary */
> >  #define	SHM_REMAP	040000	/* take-over region on attach */
> >  #define	SHM_EXEC	0100000	/* execution access */
> > +#define	SHM_MAP_HINT	0200000	/* interpret attach address as a hint */
>=20
> search hint

Ok.

> > @@ -892,7 +892,7 @@ long do_shmat(int shmid, char __user *shmaddr, int =
shmflg, ulong *raddr)
> >  	sfd->vm_ops =3D NULL;
> > =20
> >  	down_write(&current->mm->mmap_sem);
> > -	if (addr && !(shmflg & SHM_REMAP)) {
> > +	if (addr && !(shmflg & (SHM_REMAP|SHM_MAP_HINT))) {
>=20
> I think you were right earlier that it can be just deleted, so why don't
> you just do that?

I want say that we shouldn't do this check if shmaddr is a search hint.
I'm not sure that check is unneeded if shmadd is the exact address.

--=20
Regards,  Kirill A. Shutemov
 + Belarus, Minsk
 + ALT Linux Team, http://www.altlinux.com/

--pf9I7BMVVzbSWLtt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjrNTYACgkQbWYnhzC5v6r75QCeJ+U4G2XEohKAT+a2U48TwnBn
oOwAn127G3sfy14CewOOtjqnlyUHJ+HX
=kT7t
-----END PGP SIGNATURE-----

--pf9I7BMVVzbSWLtt--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
