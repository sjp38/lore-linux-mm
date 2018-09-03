Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0FF6B6823
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 09:42:25 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id p105-v6so555084wrc.11
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 06:42:25 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id l12-v6si16604394wro.140.2018.09.03.06.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 06:42:24 -0700 (PDT)
Date: Mon, 3 Sep 2018 15:42:22 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH AUTOSEL 4.4 22/47] x86/mm: Remove in_nmi() warning from
 vmalloc_fault()
Message-ID: <20180903134222.GA9051@amd>
References: <20180902131533.184092-1-alexander.levin@microsoft.com>
 <20180902131533.184092-22-alexander.levin@microsoft.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xHFwDpU9dbj6ez1V"
Content-Disposition: inline
In-Reply-To: <20180902131533.184092-22-alexander.levin@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Joerg Roedel <jroedel@suse.de>, Thomas Gleixner <tglx@linutronix.de>, "H . Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "aliguori@amazon.com" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, "hughd@google.com" <hughd@google.com>, "keescook@google.com" <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, "joro@8bytes.org" <joro@8bytes.org>


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun 2018-09-02 13:16:04, Sasha Levin wrote:
> From: Joerg Roedel <jroedel@suse.de>
>=20
> [ Upstream commit 6863ea0cda8725072522cd78bda332d9a0b73150 ]
>=20
> It is perfectly okay to take page-faults, especially on the
> vmalloc area while executing an NMI handler. Remove the
> warning.

I don't think this meets stable kernel criteria, as documented.
								Pavel
							=09
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--xHFwDpU9dbj6ez1V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAluNOj4ACgkQMOfwapXb+vLQ5ACggisQLs6xPNkrhLyLzaD65oRe
eN0An2dy6POaB9++gQ4es36+ZqRbEOTc
=gAlJ
-----END PGP SIGNATURE-----

--xHFwDpU9dbj6ez1V--
