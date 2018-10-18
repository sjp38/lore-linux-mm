Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Thu, 18 Oct 2018 11:31:25 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v5 03/27] x86/fpu/xstate: Introduce XSAVES system states
Message-ID: <20181018093125.GB10861@amd>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-4-yu-cheng.yu@intel.com>
 <20181017104137.GE22535@zn.tnic>
 <32da559b-7958-60db-e328-f0eb316e668e@infradead.org>
 <20181017225829.GA32023@zn.tnic>
 <fde4c237-6210-f4e4-5362-c2e24a9916a2@infradead.org>
 <20181018092603.GB20831@zn.tnic>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="CUfgB8w4ZwR/yMy5"
Content-Disposition: inline
In-Reply-To: <20181018092603.GB20831@zn.tnic>
Sender: linux-kernel-owner@vger.kernel.org
To: Borislav Petkov <bp@alien8.de>
Cc: Randy Dunlap <rdunlap@infradead.org>, Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
List-ID: <linux-mm.kvack.org>


--CUfgB8w4ZwR/yMy5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2018-10-18 11:26:03, Borislav Petkov wrote:
> On Wed, Oct 17, 2018 at 04:17:01PM -0700, Randy Dunlap wrote:
> > I asked what I really wanted to know.
>=20
> Then the answer is a bit better readability, I'd guess.

Normally, similar local variables are grouped together, with
initialized variables giving additional constraints.

Additionally sorting them with length ... gives too much constraints
to the author. We want readable sources, not neat ascii art everywhere.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--CUfgB8w4ZwR/yMy5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlvIUu0ACgkQMOfwapXb+vJZyACgn99kve8+2WEyYpLJ7yB+0qS+
ctcAoMNGUikTEw2fbI/IwxPsp3/Jpr6K
=dsBJ
-----END PGP SIGNATURE-----

--CUfgB8w4ZwR/yMy5--
