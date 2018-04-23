Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D06D6B000A
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 15:38:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r23-v6so741098wrc.2
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 12:38:28 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id g43-v6si10014546wrd.88.2018.04.23.12.38.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 12:38:26 -0700 (PDT)
Date: Mon, 23 Apr 2018 21:38:25 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 00/37 v6] PTI support for x86-32
Message-ID: <20180423193825.GA3827@amd>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Content-Disposition: inline
In-Reply-To: <1524498460-25530-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> here is the new version of my PTI patches for x86-32 which
> implement last weeks review comments.

Let me test the series:

Applying: x86/entry/32: Leave the kernel via trampoline stack
/data/l/linux-next-32/.git/rebase-apply/patch:80: trailing whitespace.
 /* Load entry stack pointer and allocate frame for eflags/eax */
 warning: 1 line adds whitespace errors.
Applying:  x86/entry/32: Introduce SAVE_ALL_NMI and RESTORE_ALL_NMI
	=09
Might be worth fixing if you'll do another iteration.

I did a quick boot and it works for me.

Tested-by: Pavel Machek <pavel@ucw.cz>

								Pavel
							=09
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlreNjEACgkQMOfwapXb+vISvgCeLVpnAlUbWwrOocy3sGGIoFcW
i5UAoItBl3gR3f45LIt6FlzGlSXdVAIG
=7PSV
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--
