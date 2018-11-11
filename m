Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Sun, 11 Nov 2018 12:31:25 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v5 04/27] x86/fpu/xstate: Add XSAVES system states for
 shadow stack
Message-ID: <20181111113125.GI27666@amd>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-5-yu-cheng.yu@intel.com>
 <CALCETrVAe8R=crVHoD5QmbN-gAW+V-Rwkwe4kQP7V7zQm9TM=Q@mail.gmail.com>
 <4295b8f786c10c469870a6d9725749ce75dcdaa2.camel@intel.com>
 <CALCETrUKzXYzRrWRdi8Z7AdAF0uZW5Gs7J4s=55dszoyzc29rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="TA4f0niHM6tHt3xR"
Content-Disposition: inline
In-Reply-To: <CALCETrUKzXYzRrWRdi8Z7AdAF0uZW5Gs7J4s=55dszoyzc29rw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>
List-ID: <linux-mm.kvack.org>


--TA4f0niHM6tHt3xR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> > > > +/*
> > > > + * State component 12 is Control flow Enforcement kernel states
> > > > + */
> > > > +struct cet_kernel_state {
> > > > +       u64 kernel_ssp; /* kernel shadow stack */
> > > > +       u64 pl1_ssp;    /* ring-1 shadow stack */
> > > > +       u64 pl2_ssp;    /* ring-2 shadow stack */
> > > > +} __packed;
> > > > +
> > >
> > > Why are these __packed?  It seems like it'll generate bad code for no
> > > obvious purpose.
> >
> > That prevents any possibility that the compiler will insert padding, al=
though in
> > 64-bit kernel this should not happen to either struct.  Also all xstate
> > components here are packed.
> >
>=20
> They both seem like bugs, perhaps.  As I understand it, __packed
> removes padding, but it also forces the compiler to expect the fields
> to be unaligned even if they are actually aligned.

This structure is shared with hardware, right? __packed seems like
right thing to do semantically.

As x86 handles unaligned accesses automatically, there should not be
much difference either way.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--TA4f0niHM6tHt3xR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlvoEw0ACgkQMOfwapXb+vLY1gCglZ9VACt9vxNg/QC9O9on/sJW
mGoAnA825hlJ7l0ichrQ9oFwIh31PPDp
=dUic
-----END PGP SIGNATURE-----

--TA4f0niHM6tHt3xR--
