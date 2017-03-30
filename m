Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D44B6B03AE
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 09:37:15 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k6so10404176wre.3
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 06:37:15 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id e2si3560688wrc.122.2017.03.30.06.37.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 06:37:13 -0700 (PDT)
Date: Thu, 30 Mar 2017 15:37:12 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2] module: check if memory leak by module.
Message-ID: <20170330133712.GA23946@amd>
References: <CGME20170329060315epcas5p1c6f7ce3aca1b2770c5e1d9aaeb1a27e1@epcas5p1.samsung.com>
 <1490767322-9914-1-git-send-email-maninder1.s@samsung.com>
 <460c5798-1f4d-6fd0-cf32-349fbd605862@virtuozzo.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PEIAKu/WMn1b1Hv9"
Content-Disposition: inline
In-Reply-To: <460c5798-1f4d-6fd0-cf32-349fbd605862@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Maninder Singh <maninder1.s@samsung.com>, jeyu@redhat.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, chris@chris-wilson.co.uk, joonas.lahtinen@linux.intel.com, mhocko@suse.com, keescook@chromium.org, jinb.park7@gmail.com, anisse@astier.eu, rafael.j.wysocki@intel.com, zijun_hu@htc.com, mingo@kernel.org, mawilcox@microsoft.com, thgarnie@google.com, joelaf@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pankaj.m@samsung.com, ajeet.y@samsung.com, hakbong5.lee@samsung.com, a.sahrawat@samsung.com, lalit.mohan@samsung.com, cpgs@samsung.com, Vaneet Narang <v.narang@samsung.com>


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

=20
>  3) This might produce false positives. E.g. module may defer vfree() in =
workqueue, so the=20
>      actual vfree() call happens after module unloaded.

Umm. Really?

I agree that module may alloc memory and pass it to someone else. Ok
so far.

But if module code executes after module is unloaded -- that is use
after free -- right?
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--PEIAKu/WMn1b1Hv9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAljdCgcACgkQMOfwapXb+vLc/ACgm3QTosZ7AzF/e1PutXhiK1sc
7OEAn0iw3DxK+F475u4NNXpSYVExn74k
=M7SU
-----END PGP SIGNATURE-----

--PEIAKu/WMn1b1Hv9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
