Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1684D6B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 05:43:45 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id 137so5915339wml.0
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 02:43:45 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id q62si6836332wmd.137.2018.02.14.02.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 02:43:43 -0800 (PST)
Date: Wed, 14 Feb 2018 11:43:42 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180214104342.GA12209@amd>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de>
 <20180210091543.ynypx4y3koz44g7y@angband.pl>
 <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
 <20180211105909.53bv5q363u7jgrsc@angband.pl>
 <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
 <0C6EFF56-F135-480C-867C-B117F114A99F@amacapital.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GvXjxJ+pjyke8COw"
Content-Disposition: inline
In-Reply-To: <0C6EFF56-F135-480C-867C-B117F114A99F@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Mark D Rustad <mrustad@gmail.com>, Adam Borowski <kilobyte@angband.pl>, Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun 2018-02-11 11:42:47, Andy Lutomirski wrote:
>=20
>=20
> On Feb 11, 2018, at 9:40 AM, Mark D Rustad <mrustad@gmail.com> wrote:
>=20
> >> On Feb 11, 2018, at 2:59 AM, Adam Borowski <kilobyte@angband.pl> wrote:
> >>=20
> >>> Does Debian make it easy to upgrade to a 64-bit kernel if you have a
> >>> 32-bit install?
> >>=20
> >> Quite easy, yeah.  Crossgrading userspace is not for the faint of the =
heart,
> >> but changing just the kernel is fine.
> >=20
> > ISTR that iscsi doesn't work when running a 64-bit kernel with a 32-bit=
 userspace. I remember someone offered kernel patches to fix it, but I thin=
k they were rejected. I haven't messed with that stuff in many years, so pe=
rhaps the userspace side now has accommodation for it. It might be somethin=
g to check on.
> >=20
>=20
> At the risk of suggesting heresy, should we consider removing x86_32 supp=
ort at some point?

We have just found out that majority of 64-bit machines are broken in
rather fundamental ways (Spectre) and Intel does not even look
interested in fixing that (because it would make them look bad on
benchmarks).

Even when the Spectre bug is mitigated... this looks like can of worms
that can not be closed.

OTOH -- we do know that there are non-broken machines out there,
unfortunately they are mostly 32-bit :-). Removing support for
majority of working machines may not be good idea...

[And I really hope future CPUs get at least option to treat cache miss
as a side-effect -- thus disalowed during speculation -- and probably
option to turn off speculation altogether. AFAICT, it should "only"
result in 50% slowdown -- or that was result in some riscv
presentation.]

									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--GvXjxJ+pjyke8COw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlqEEt4ACgkQMOfwapXb+vKwvQCeIXEkHk0gIuij6jJeJ8L9JpaQ
OVUAn2Jr3gvFOK5Qz+8M3nnE2T54bLHV
=30Yq
-----END PGP SIGNATURE-----

--GvXjxJ+pjyke8COw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
