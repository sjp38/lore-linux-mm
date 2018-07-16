Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0DD66B026B
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 03:51:50 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r1-v6so8090683wrp.11
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 00:51:50 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id p200-v6si9471448wmd.66.2018.07.16.00.51.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 00:51:49 -0700 (PDT)
Date: Mon, 16 Jul 2018 09:51:48 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 00/39 v7] PTI support for x86-32
Message-ID: <20180716075148.GA10794@amd>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C7zPtVaVf+AK4Oqc"
Content-Disposition: inline
In-Reply-To: <1531308586-29340-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> here is version 7 of my patches to enable PTI on x86-32.
> Changes to the previous version are:
>=20
> 	* Rebased to v4.18-rc4
>=20
> 	* Introduced pti_finalize() which is called after
> 	  mark_readonly() and used to update the kernel
> 	  mappings in the user page-table after RO/NX
> 	  protections are in place.
>=20
> The patches need the vmalloc/ioremap fixes in tip/x86/mm to
> work correctly, because this enablement makes the issues
> fixed there more likely to happen.
>=20
> I did the load-testing again with 'perf top', the ldt_gdt
> self-test and a kernel-compile running in a loop again. The
> patches posted here were tested for 16 hours without any
> regression showing up. An earlier version of these patches
> based on v4.18-rc1 survived this test for over a week before
> I canceled the test. The test ran with enabled CR3 debugging
> added in the last patch of this series.

Would it make sense to merge the part of the series that was reviewed
without comments? It would get at least part of the series testing in
-next....

								Pavel
							=09
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--C7zPtVaVf+AK4Oqc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAltMTpQACgkQMOfwapXb+vLIKACbB/Q+v4hVGhChiR3UgMdV4XP4
GG0AoI3pzik+gBn6LveC+9+75BpALLw2
=CyC3
-----END PGP SIGNATURE-----

--C7zPtVaVf+AK4Oqc--
