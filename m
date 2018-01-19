Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67A696B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 05:55:31 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c11so967067wrb.23
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 02:55:31 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id m25si8128656wrb.162.2018.01.19.02.55.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 02:55:30 -0800 (PST)
Date: Fri, 19 Jan 2018 11:55:28 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180119105527.GB29725@amd>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZfOjI3PrQbgiZnxM"
Content-Disposition: inline
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de


--ZfOjI3PrQbgiZnxM
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> From: Joerg Roedel <jroedel@suse.de>
>=20
> Hi,
>=20
> here is my current WIP code to enable PTI on x86-32. It is
> still in a pretty early state, but it successfully boots my
> KVM guest with PAE and with legacy paging. The existing PTI
> code for x86-64 already prepares a lot of the stuff needed
> for 32 bit too, thanks for that to all the people involved
> in its development :)

Thanks for doing the work.

I tried applying it on top of -next, and that did not succeed. Let me
try Linus tree...

> The code has not run on bare-metal yet, I'll test that in
> the next days once I setup a 32 bit box again. I also havn't
> tested Wine and DosEMU yet, so this might also be broken.

Um. Ok, testing is something I can do. At least I have excuse to power
on T40p.

Ok... Testing is something I can do... If I can get it to compile.

  CC      arch/x86/mm/dump_pagetables.o
  arch/x86/mm/dump_pagetables.c: In function
  =E2=80=98ptdump_walk_user_pgd_level_checkwx=E2=80=99:
  arch/x86/mm/dump_pagetables.c:546:26: error: =E2=80=98init_top_pgt=E2=80=
=99
  undeclared (first use in this function)
    pgd_t *pgd =3D (pgd_t *) &init_top_pgt;
                              ^
			      arch/x86/mm/dump_pagetables.c:546:26:
  note: each undeclared identifier is reported only once for each
  function it appears in
  scripts/Makefile.build:316: recipe for target
  'arch/x86/mm/dump_pagetables.o' failed
  make[2]: *** [arch/x86/mm/dump_pagetables.o] Error 1
  scripts/Makefile.build:575: recipe for target 'arch/x86/mm' failed
  make[1]: *** [arch/x86/mm] Error 2
  make[1]: *** Waiting for unfinished jobs....
    CC      arch/x86/platform/intel/iosf_mbi.o
   =20
Ok, I guess I can disable some config option...
								Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--ZfOjI3PrQbgiZnxM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlphzp8ACgkQMOfwapXb+vJJTwCgqKLRKD1mKRaeVYX66fFsYamu
7yIAoI0EoZckBNrg01y4Ogj10vnf+FdS
=vixT
-----END PGP SIGNATURE-----

--ZfOjI3PrQbgiZnxM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
