Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8096B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:39:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n22-v6so1243261wmc.6
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 06:39:38 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id j7-v6si1227163wmd.131.2018.07.24.06.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 06:39:36 -0700 (PDT)
Date: Tue, 24 Jul 2018 15:39:35 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
Message-ID: <20180724133935.GA30797@amd>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <20180723140925.GA4285@amd>
 <CA+55aFynT9Sp7CbnB=GqLbns7GFZbv3pDSQm_h0jFvJpz3ES+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mP3DRpeJDSE+ciuQ"
Content-Disposition: inline
In-Reply-To: <CA+55aFynT9Sp7CbnB=GqLbns7GFZbv3pDSQm_h0jFvJpz3ES+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?iso-8859-1?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-07-23 12:00:08, Linus Torvalds wrote:
> On Mon, Jul 23, 2018 at 7:09 AM Pavel Machek <pavel@ucw.cz> wrote:
> >
> > Meanwhile... it looks like gcc is not slowed down significantly, but
> > other stuff sees 30% .. 40% slowdowns... which is rather
> > significant.
>=20
> That is more or less expected.

Ok, so I was wrong. bzip2 showed 30% slowdown, but running test in a
loop, I get (on v4.18) that, too.

That tells me that something is wrong with machine I'm using for
benchmarking. Whether KPTI  is enabled can still be measured with the
bzip2 pipeline, but the effect is far more subtle.

							Pavel

pavel@amd:~$ while true; do time cat /dev/urandom | head -c 10000000 |
bzip2 -9 - | wc -c ; done10044031
3.87user 0.91system 4.62 (0m4.622s) elapsed 103.48%CPU
10044234
4.03user 0.82system 4.68 (0m4.688s) elapsed 103.67%CPU
10043664
4.28user 0.85system 4.99 (0m4.994s) elapsed 102.90%CPU
10045959
4.43user 0.85system 5.12 (0m5.121s) elapsed 103.44%CPU
10043829
4.50user 0.89system 5.22 (0m5.228s) elapsed 103.22%CPU
10044296
4.65user 0.93system 5.39 (0m5.398s) elapsed 103.61%CPU
10045311
4.76user 0.93system 5.47 (0m5.479s) elapsed 103.98%CPU
10043819
4.81user 0.93system 5.55 (0m5.556s) elapsed 103.37%CPU
10045097
4.72user 1.04system 5.59 (0m5.597s) elapsed 103.01%CPU
10044012
4.86user 0.97system 5.68 (0m5.684s) elapsed 102.79%CPU
10044569
4.93user 0.96system 5.72 (0m5.728s) elapsed 102.92%CPU
10044141
4.94user 0.98system 5.75 (0m5.752s) elapsed 102.97%CPU
10043695
4.97user 0.95system 5.76 (0m5.768s) elapsed 102.87%CPU
10045690
5.12user 0.94system 5.90 (0m5.901s) elapsed 102.79%CPU
10045153
5.06user 1.00system 5.88 (0m5.883s) elapsed 103.21%CPU
10044560
5.10user 1.01system 5.92 (0m5.927s) elapsed 103.31%CPU
10044845
5.17user 0.99system 5.96 (0m5.960s) elapsed 103.44%CPU
10043884
5.15user 1.03system 6.00 (0m6.004s) elapsed 103.14%CPU
10044286
5.18user 1.01system 6.00 (0m6.002s) elapsed 103.40%CPU
10045749
5.00user 1.22system 6.04 (0m6.044s) elapsed 102.98%CPU
10044098
5.22user 1.02system 6.05 (0m6.053s) elapsed 103.21%CPU
10045326
5.20user 1.01system 6.04 (0m6.048s) elapsed 102.72%CPU
10042365
5.22user 1.03system 6.06 (0m6.061s) elapsed 103.30%CPU
10043952
5.24user 1.00system 6.06 (0m6.069s) elapsed 102.97%CPU
10044569
5.30user 1.00system 6.09 (0m6.099s) elapsed 103.46%CPU
10043241
5.26user 1.00system 6.09 (0m6.097s) elapsed 102.79%CPU
10044797
5.30user 1.01system 6.11 (0m6.114s) elapsed 103.46%CPU
10043711
5.25user 1.02system 6.09 (0m6.093s) elapsed 103.03%CPU
10043882
5.31user 1.01system 6.13 (0m6.131s) elapsed 103.28%CPU
10043571
5.26user 1.05system 6.13 (0m6.133s) elapsed 103.06%CPU
10044742
5.29user 1.03system 6.12 (0m6.122s) elapsed 103.25%CPU
10044170
5.35user 1.04system 6.18 (0m6.183s) elapsed 103.60%CPU
10043542
5.22user 1.12system 6.17 (0m6.172s) elapsed 102.89%CPU
10042985
5.25user 1.13system 6.19 (0m6.193s) elapsed 103.09%CPU
10044102
5.36user 1.01system 6.17 (0m6.177s) elapsed 103.17%CPU
10044609
5.48user 0.99system 6.28 (0m6.284s) elapsed 103.11%CPU
10045185
5.40user 1.03system 6.23 (0m6.236s) elapsed 103.29%CPU
10044444
5.41user 1.06system 6.25 (0m6.255s) elapsed 103.55%CPU
10044859
5.35user 1.04system 6.20 (0m6.201s) elapsed 103.17%CPU
10045613

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--mP3DRpeJDSE+ciuQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAltXLBcACgkQMOfwapXb+vK56gCgwX7rJBTTLPDG9JDUVAJy0PXf
dPcAoK4jHYpGkFcIWcRE+rz19YT7+ltU
=altz
-----END PGP SIGNATURE-----

--mP3DRpeJDSE+ciuQ--
