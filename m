Received: by ey-out-1920.google.com with SMTP id 21so1040413eyc.44
        for <linux-mm@kvack.org>; Mon, 06 Oct 2008 03:11:16 -0700 (PDT)
Date: Mon, 6 Oct 2008 13:12:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
Message-ID: <20081006101221.GA21183@localhost.localdomain>
References: <1223017469-5158-1-git-send-email-kirill@shutemov.name> <20081003080244.GC25408@elte.hu> <20081003092550.GA8669@localhost.localdomain> <87abdintds.fsf@basil.nowhere.org> <20081006081717.GA20072@localhost.localdomain> <20081006084246.GC3180@one.firstfloor.org> <20081006091709.GB20852@localhost.localdomain> <20081006095628.GE3180@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="X1bOJ3K7DJ5YkBrT"
Content-Disposition: inline
In-Reply-To: <20081006095628.GE3180@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 06, 2008 at 11:56:28AM +0200, Andi Kleen wrote:
> > > And personality() is not thread local/safe, so it's not a particularly
> > > good interface to use later.
> >=20
> > qemu can call personality() before any threads will be created.
>=20
> It still makes it unsuitable for a lot of other applications.
> e.g. a JVM using 32bit pointers couldn't use it because it would
> affect native C threads running in the same process.
>=20
> >=20
> > > Per system call switches are preferable
> > > and more flexible.
> >=20
> > Per syscall switches are cool, but I don't see any advantage from it fo=
r=20
> > qemu.
>=20
> Linux interfaces are not supposed to be "interfaces for qemu" but general=
ly
> applicable interfaces.

I know. What about adding both personality() and flag for shmat()? I can
prepare patch that implement flag for shmat().

--=20
Regards,  Kirill A. Shutemov
 + Belarus, Minsk
 + ALT Linux Team, http://www.altlinux.com/

--X1bOJ3K7DJ5YkBrT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjp5IUACgkQbWYnhzC5v6r27gCeNx/R+jvdBxMx+XsaOSFUWgPL
/gUAnjl+VmSuM/QGVmbjMn5MgKyxSlpi
=X0kf
-----END PGP SIGNATURE-----

--X1bOJ3K7DJ5YkBrT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
