Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Sun, 11 Nov 2018 20:02:30 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v5 04/27] x86/fpu/xstate: Add XSAVES system states for
 shadow stack
Message-ID: <20181111190230.GA2681@amd>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-5-yu-cheng.yu@intel.com>
 <20181108184038.GJ7543@zn.tnic>
 <20181111113103.GG27666@amd>
 <4E917DA9-5192-48E2-8857-08C3ABE08AFE@amacapital.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="azLHFNyN32YCQGCU"
Content-Disposition: inline
In-Reply-To: <4E917DA9-5192-48E2-8857-08C3ABE08AFE@amacapital.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>, Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
List-ID: <linux-mm.kvack.org>


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun 2018-11-11 06:59:24, Andy Lutomirski wrote:
>=20
>=20
> > On Nov 11, 2018, at 3:31 AM, Pavel Machek <pavel@ucw.cz> wrote:
> >=20
> > Hi!
> >=20
> >>> +/*
> >>> + * State component 12 is Control flow Enforcement kernel states
> >>> + */
> >>> +struct cet_kernel_state {
> >>> +    u64 kernel_ssp;    /* kernel shadow stack */
> >>> +    u64 pl1_ssp;    /* ring-1 shadow stack */
> >>> +    u64 pl2_ssp;    /* ring-2 shadow stack */
> >>=20
> >> Just write "privilege level" everywhere - not "ring".
> >=20
> > Please just use word "ring". It is well estabilished terminology.
> >=20
> > Which ring is priviledge level 1, given that we have SMM and
> > virtualization support?
>=20
> To the contrary: CPL, DPL, and RPL are very well defined terms in the arc=
hitecture manuals. =E2=80=9CPL=E2=80=9D is privilege level. PL 1 is very we=
ll defined.
>=20

"Priviledge level" is generic term. "CPL" I may recognize as
Intel-specific. "priviledge level" I would not. So I'd really use
"ring" there. "CPL 1 shadow stack" would be okay, too I guess.

> SMM is SMM, full stop (unless dual mode or whatever it=E2=80=99s called i=
s on, but AFAIK no one uses it).  VMX non-root CPL 1 is *still* privilege l=
evel 1.
>=20
> In contrast, the security community likes to call SMM =E2=80=9Cring -1=E2=
=80=9D, which is cute, but wrong from a systems programmer view. For exampl=
e, SMM=E2=80=99s CPL can still range from 0-3.
>=20

Regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--azLHFNyN32YCQGCU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlvofMYACgkQMOfwapXb+vI9WgCfSA5mLeg0dMNk4A/6IbLq/9Ih
RVoAnA4XuVV1d1EoMJO4lhfDC+rwf0qd
=xaDH
-----END PGP SIGNATURE-----

--azLHFNyN32YCQGCU--
