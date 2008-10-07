Received: by ey-out-1920.google.com with SMTP id 21so1294138eyc.44
        for <linux-mm@kvack.org>; Tue, 07 Oct 2008 04:23:14 -0700 (PDT)
Date: Tue, 7 Oct 2008 14:24:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC] shmat: introduce flag SHM_MAP_HINT
Message-ID: <20081007112418.GC5126@localhost.localdomain>
References: <20081006132651.GG3180@one.firstfloor.org> <1223303879-5555-1-git-send-email-kirill@shutemov.name> <20081007195837.5A6B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="B4IIlcmfBL/1gGOG"
Content-Disposition: inline
In-Reply-To: <20081007195837.5A6B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--B4IIlcmfBL/1gGOG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 07, 2008 at 08:08:19PM +0900, KOSAKI Motohiro wrote:
> > It allows interpret attach address as a hint, not as exact address.
> >=20
> > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Andi Kleen <andi@firstfloor.org>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: Arjan van de Ven <arjan@infradead.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >  include/linux/shm.h |    1 +
> >  ipc/shm.c           |    4 ++--
> >  2 files changed, 3 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/include/linux/shm.h b/include/linux/shm.h
> > index eca6235..2a637b8 100644
> > --- a/include/linux/shm.h
> > +++ b/include/linux/shm.h
> > @@ -55,6 +55,7 @@ struct shmid_ds {
> >  #define	SHM_RND		020000	/* round attach address to SHMLBA boundary */
> >  #define	SHM_REMAP	040000	/* take-over region on attach */
> >  #define	SHM_EXEC	0100000	/* execution access */
> > +#define	SHM_MAP_HINT	0200000	/* interpret attach address as a hint */
>=20
> hmm..
> Honestly, I don't like that qemu specific feature insert into shmem core.
> At least, this patch is too few comments.
> Therefore, an develpper can't understand why SHM_MAP_HINT exist.
>=20
> I think this patch description is too short and too poor.
> I don't like increasing mysterious interface.

Sorry for it. I'll fix it in next patch version.

--=20
Regards,  Kirill A. Shutemov
 + Belarus, Minsk
 + ALT Linux Team, http://www.altlinux.com/

--B4IIlcmfBL/1gGOG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjrRuIACgkQbWYnhzC5v6qZ1QCgkS8pVZ30bgW169woJ1ah74bV
DCgAoIw/oVmYpqCFChklzZIs7q79GPAy
=YCjq
-----END PGP SIGNATURE-----

--B4IIlcmfBL/1gGOG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
