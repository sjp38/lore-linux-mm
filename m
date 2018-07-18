Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2454A6B000D
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:00:04 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id w2-v6so1854412wrt.13
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:00:04 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id e17-v6si2652792wrj.406.2018.07.18.05.00.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 05:00:02 -0700 (PDT)
Date: Wed, 18 Jul 2018 13:59:57 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 00/39 v8] PTI support for x86-32
Message-ID: <20180718115957.GA23157@amd>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6c2NcOVqGQ03X4Wi"
Content-Disposition: inline
In-Reply-To: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed 2018-07-18 11:40:37, Joerg Roedel wrote:
> Hi,
>=20
> here is version 8 of my patches to enable PTI on x86-32. The
> last version got some good review which I mostly worked into
> this version.


> for easier testing. The code survived >12h overnight testing
> with my usual
>=20
> 	* 'perf top' for NMI load
>=20
> 	* x86-selftests in a loop (except mpx and pkeys
> 	  which are not supported on the machine)
>=20
> 	* kernel-compile in a loop
>=20
> all in parallel. I also boot-tested x86-64 and !PAE config
> again and ran my GLB-test to make sure that the global
> mappings between user and kernel page-table are identical.
> All that succeeded and showed no regressions.

For the record:

Tested-by: Pavel Machek <pavel@ucw.cz>

(on top of .18.0-rc5-next-20180718)

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--6c2NcOVqGQ03X4Wi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAltPK70ACgkQMOfwapXb+vLILACdF5fdD/3UabcoQ6uWeZKLloG+
LcEAnRHN546y9wVWUOYJtYl2S7rfDisl
=KJSr
-----END PGP SIGNATURE-----

--6c2NcOVqGQ03X4Wi--
