Date: Fri, 17 Oct 2008 18:46:30 +0200
From: Kurt Garloff <garloff@suse.de>
Subject: Re: [garloff@suse.de: [PATCH 1/1] default mlock limit 32k->64k]
Message-ID: <20081017164630.GL5286@tpkurt2.garloff.de>
References: <20081016074319.GD5286@tpkurt2.garloff.de> <20081016154816.c53a6f8e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qWQny9krlSHwPXz2"
Content-Disposition: inline
In-Reply-To: <20081016154816.c53a6f8e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, NPiggin@suse.de
List-ID: <linux-mm.kvack.org>

--qWQny9krlSHwPXz2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Andrew,

On Thu, Oct 16, 2008 at 03:48:16PM -0700, Andrew Morton wrote:
> On Thu, 16 Oct 2008 09:43:19 +0200 Kurt Garloff <garloff@suse.de> wrote:
> > Index: linux-2.6.27/include/linux/resource.h
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux-2.6.27.orig/include/linux/resource.h
> > +++ linux-2.6.27/include/linux/resource.h
> > @@ -59,10 +59,10 @@ struct rlimit {
> >  #define _STK_LIM	(8*1024*1024)
> > =20
> >  /*
> > - * GPG wants 32kB of mlocked memory, to make sure pass phrases
> > + * GPG2 wants 64kB of mlocked memory, to make sure pass phrases
> >   * and other sensitive information are never written to disk.
> >   */
> > -#define MLOCK_LIMIT	(8 * PAGE_SIZE)
> > +#define MLOCK_LIMIT	((PAGE_SIZE > 64*1024) ? PAGE_SIZE : 64*1024)
>=20
> I dunno.  Is there really much point in chasing userspace changes like
> this?

If there were many apps that would need it and that would have
contradicting or fast changing requirements, I would certainly
not wanna chase that.

We're lucky here that gpg/gpg2 is the only unprivileged user
of locked memory and that the requirement does not really change
often. We've had gpg1 with 32k need since 1999 and now gpg2 with
a 64k need.

Accommodating that seems like a pragmatic thing to do. Will ensure
good defaults for a broad set of users.

> Worst case, we end up releasing distributions which work properly on
> newer kernels and which fail to work properly on older kernels.

I know a number of users that run new kernels below old distributions
but few that do the opposite.
The failure mode in this specific case is not obscure at all, so I'm
not worried:=20
can't lock memory: Cannot allocate memory
Warning: using insecure memory!

> I suspect that it would be better to set the default to zero and
> *force* userspace to correctly tune whatever-kernel-they're-running-on
> to match their requirements.

That's feasible, though I think distributions are not today
preconfigured to do that. Turning your argument around:
It would it a bit harder to run new kernels on old distros.
(Which I believe is worse -- we need testers!)

Best,
--=20
Kurt Garloff, VP Business Development -- OPS, Novell Inc.

--qWQny9krlSHwPXz2
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)

iD8DBQFI+MFmxmLh6hyYd04RAnvMAJ9WZosJUvKQToc3n+zOWFir5XLVHACgtrIl
6RXOcYl1bVnNIABDacpTz7s=
=Z96D
-----END PGP SIGNATURE-----

--qWQny9krlSHwPXz2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
