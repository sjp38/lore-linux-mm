Received: by nf-out-0910.google.com with SMTP id c10so1266166nfd.6
        for <linux-mm@kvack.org>; Mon, 06 Oct 2008 02:16:07 -0700 (PDT)
Date: Mon, 6 Oct 2008 12:17:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
Message-ID: <20081006091709.GB20852@localhost.localdomain>
References: <1223017469-5158-1-git-send-email-kirill@shutemov.name> <20081003080244.GC25408@elte.hu> <20081003092550.GA8669@localhost.localdomain> <87abdintds.fsf@basil.nowhere.org> <20081006081717.GA20072@localhost.localdomain> <20081006084246.GC3180@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/WwmFnJnmDyWGHa4"
Content-Disposition: inline
In-Reply-To: <20081006084246.GC3180@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--/WwmFnJnmDyWGHa4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 06, 2008 at 10:42:46AM +0200, Andi Kleen wrote:
> On Mon, Oct 06, 2008 at 11:17:23AM +0300, Kirill A. Shutemov wrote:
> > On Mon, Oct 06, 2008 at 08:13:19AM +0200, Andi Kleen wrote:
> > > Unfortunately that doesn't work for shmat() because the address argum=
ent
> > > is not a search hint, but a fixed address.=20
> > >=20
> > > I presume you need this for the qemu syscall emulation. For a standard
> > > application I would just recommend to use mmap with tmpfs instead
> > > (sysv shm is kind of obsolete). For shmat() emulation the cleanest way
> > > would be probably to add a new flag to shmat() that says that address
> > > is a search hint, not a fixed address. Then implement it the way reco=
mmended
> > > above.
> >=20
> > I prefer one handle to switch application to 32-bit address mode. Why i=
s it
> > wrong?
>=20
> "32 bit mode" really has to be set at exec time, otherwise it is not
> (e.g. the stack will be beyond).

Stack isn't a problem for qemu. qemu allocate stack for target application
by itself.

> And personality() is not thread local/safe, so it's not a particularly
> good interface to use later.

qemu can call personality() before any threads will be created.

> Per system call switches are preferable
> and more flexible.

Per syscall switches are cool, but I don't see any advantage from it for=20
qemu.

--=20
Regards,  Kirill A. Shutemov
 + Belarus, Minsk
 + ALT Linux Team, http://www.altlinux.com/

--/WwmFnJnmDyWGHa4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjp15UACgkQbWYnhzC5v6qV2QCeNlyCez2Win898hSL08zNcwn+
FrgAn1iR+luBG1dnbdbceKtawQCz4sAr
=hmIl
-----END PGP SIGNATURE-----

--/WwmFnJnmDyWGHa4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
