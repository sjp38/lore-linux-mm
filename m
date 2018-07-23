Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9941D6B026B
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 17:55:59 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r1-v6so950399wrp.11
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 14:55:59 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id v7-v6si8182469wre.88.2018.07.23.14.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 14:55:58 -0700 (PDT)
Date: Mon, 23 Jul 2018 23:55:57 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
Message-ID: <20180723215557.GA3935@amd>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <20180723140925.GA4285@amd>
 <CA+55aFynT9Sp7CbnB=GqLbns7GFZbv3pDSQm_h0jFvJpz3ES+g@mail.gmail.com>
 <20180723213830.GA4632@amd>
 <39A1C149-DA03-46D1-801F-0205DCD69A36@amacapital.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline
In-Reply-To: <39A1C149-DA03-46D1-801F-0205DCD69A36@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?iso-8859-1?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > What I want is "if A can ptrace B, and B has pti disabled, A can have
> > pti disabled as well". Now.. I see someone may want to have it
> > per-thread, because for stuff like javascript JIT, thread may have
> > rights to call ptrace, but is unable to call ptrace because JIT
> > removed that ability... hmm...
>=20
> No, you don=E2=80=99t want that. The problem is that Meltdown isn=E2=80=
=99t a problem that exists in isolation. It=E2=80=99s very plausible that J=
avaScript code could trigger a speculation attack that, with PTI off, could=
 read kernel memory.

Yeah, the web browser threads that run javascript code should have PTI
on. But maybe I want the rest of web browser with PTI off.

So... yes, I see why someone may want it per-thread (and not
per-process).

I guess per-process would be good enough for me. Actually, maybe even
per-uid. I don't have any fancy security here, so anything running uid
0 and 1000 is close enough to trusted.

								Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAltWTu0ACgkQMOfwapXb+vLAHgCgwm6vHy+tGQo0EQEDMfrLuUJl
GoQAn1fCFV/6RZlLyzusdi9BI7Xn3jNe
=edDv
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
