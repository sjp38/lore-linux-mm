Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 175B96B0269
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:07:10 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u1-v6so3547486wrs.18
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 14:07:10 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id d1-v6si4020822wrr.220.2018.07.11.14.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 14:07:09 -0700 (PDT)
Date: Wed, 11 Jul 2018 23:07:02 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 00/39 v7] PTI support for x86-32
Message-ID: <20180711210702.GA23921@amd>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <CA+55aFzrG+GV5ySVUiiod8Va5P0_vmUuh25Pner1r7c_aQgH9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HcAYCG3uE/tztfnV"
Content-Disposition: inline
In-Reply-To: <CA+55aFzrG+GV5ySVUiiod8Va5P0_vmUuh25Pner1r7c_aQgH9g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?iso-8859-1?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>


--HcAYCG3uE/tztfnV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed 2018-07-11 09:28:39, Linus Torvalds wrote:
> On Wed, Jul 11, 2018 at 4:30 AM Joerg Roedel <joro@8bytes.org> wrote:
> >
> > I did the load-testing again with 'perf top', the ldt_gdt
> > self-test and a kernel-compile running in a loop again.
>=20
> So none of the patches looked scary to me, but then, neither did
> earlier versions.
>=20
> It's the testing that worries me most. Pretty much no developers run
> 32-bit any more, and I'd be most worried about the odd interactions
> that might be hw-specific. Some crazy EFI mapping setup or the similar
> odd case that simply requires a particular configuration or setup.

I tested previous version of the series, and I keep testing -next on
thinkpad X60 every week or so. I try to test every major release on
T40p.

> But I guess those issues will never be found until we just spring this
> all on the unsuspecting public.

Sounds like a plan. Testing gets easier once patch reaches -next or
mainline...

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--HcAYCG3uE/tztfnV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAltGcXYACgkQMOfwapXb+vLyIgCgrLHSw4fI1oPd+6TIcFvflT7F
3ucAnAr3LZNxy7dELmcZ0Y5nmY8G1yI2
=IiwM
-----END PGP SIGNATURE-----

--HcAYCG3uE/tztfnV--
