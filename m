Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 31C366B000A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 10:09:28 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id 40-v6so376871wrb.23
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:09:28 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id t131-v6si5818860wmb.31.2018.07.23.07.09.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 07:09:27 -0700 (PDT)
Date: Mon, 23 Jul 2018 16:09:25 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
Message-ID: <20180723140925.GA4285@amd>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Content-Disposition: inline
In-Reply-To: <1532103744-31902-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> here are 3 patches which update the PTI-x86-32 patches recently merged
> into the tip-tree. The patches are ordered by importance:

It seems PTI is now in -next. I'll test that soon.

Meanwhile... it looks like gcc is not slowed down significantly, but
other stuff sees 30% .. 40% slowdowns... which is rather
significant.

Would it be possible to have per-process control of kpti? I have
some processes where trading of speed for security would make sense.

Best regards,
								Pavel

cd ~/g/tui/nowcast
time ./nowcast -x (30%)
KPTI: 139.25user 73.65system 269.90 (4m29.901s) elapsed 78.88%CPU
      133.35user 73.15system 228.80 (3m48.802s) elapsed 90.25%CPU
      140.51user 74.21system 218.33 (3m38.338s) elapsed 98.34%CPU
      133.85user 75.89system 212.02 (3m32.026s) elapsed 98.93%CPU (no chrom=
ium)
      139.34user 75.00system 235.75 (3m55.752s) elapsed 90.92%CPU
     =20
4.18: 116.99user 43.79system 217.65 (3m37.653s) elapsed 73.87%CPU
      115.14user 43.97system 178.85 (2m58.855s) elapsed 88.96%CPU
      128.47user 47.22system 178.24 (2m58.245s) elapsed 98.57%CPU
      132.30user 49.27system 184.40 (3m4.408s) elapsed 98.46%CPU
      134.88user 48.59system 186.67 (3m6.673s) elapsed 98.29%CPU
      132.15user 48.65system 524.68 (8m44.684s) elapsed 34.46%CPU
      120.38user 45.45system 168.72 (2m48.720s) elapsed 98.29%CPU
     =20
time cat /dev/urandom | head -c 10000000 |  bzip2 -9 - | wc -c (40%)
v4.18: 4.57user 0.23system 4.64 (0m4.644s) elapsed 103.53%CPU
       4.86user 0.23system 4.95 (0m4.952s) elapsed 102.81%CPU
       5.13user 0.22system 5.19 (0m5.190s) elapsed 103.14%CPU
KPTI:  6.39user 0.48system 6.74 (0m6.747s) elapsed 101.96%CPU
       6.66user 0.41system 6.91 (0m6.912s) elapsed 102.51%CPU
       6.53user 0.51system 6.91 (0m6.919s) elapsed 101.99%CPU

v4l-utils: make clean, time make
v4.18: 191.93user 11.00system 211.19 (3m31.191s) elapsed 96.09%CPU
       221.21user 14.69system 248.73 (4m8.734s) elapsed 94.84%CPU
       198.35user 11.61system 211.39 (3m31.392s) elapsed 99.32%CPU
       204.87user 11.69system 217.97 (3m37.971s) elapsed 99.35%CPU
       203.68user 11.88system 217.29 (3m37.291s) elapsed 99.20%CPU
KPTI:  156.45user 40.08system 204.77 (3m24.777s) elapsed 95.97%CPU
       183.32user 38.64system 225.03 (3m45.031s) elapsed 98.63%CPU

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAltV4ZUACgkQMOfwapXb+vK9BQCgm16A64iYQ44YNBiSaJr98m5v
4iEAn1EsSZFdDWhAgAGh64B/6Io8GbyD
=8oHa
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--
