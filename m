Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 558A76B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 16:54:39 -0400 (EDT)
Received: by igbud6 with SMTP id ud6so112943504igb.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:54:39 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id v29si2886648iov.99.2015.03.25.13.54.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 13:54:38 -0700 (PDT)
Received: by iecvj10 with SMTP id vj10so32187067iec.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:54:38 -0700 (PDT)
Message-ID: <5513208D.5070306@gmail.com>
Date: Wed, 25 Mar 2015 16:54:37 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>	<20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>	<550A5FF8.90504@gmail.com> <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com> <550E6D9D.1060507@gmail.com> <5512E0C0.6060406@suse.cz> <55131F70.7020503@gmail.com>
In-Reply-To: <55131F70.7020503@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="5KQCGTSHefEHmhHWbhXnsqUeMgPTRsNqc"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Aliaksey Kandratsenka <alkondratenko@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--5KQCGTSHefEHmhHWbhXnsqUeMgPTRsNqc
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> The page fault heuristic is just way too aggressive because there's no
> indication of how much memory will be used. I don't think it makes sens=
e
> to do it without an explicit MADV_NOHUGEPAGE. Collapsing only dense
> ranges doesn't have the same risk.

Er, without an explicit MADV_HUGEPAGE*.


--5KQCGTSHefEHmhHWbhXnsqUeMgPTRsNqc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVEyCNAAoJEPnnEuWa9fIqMRgP/1p0X2zMQ6p/sdUyANJOMhmO
+Rpfby3GBQ0PYVzJFcZHU98+Gh2Y6DPsrKVi6FJBTGIqY092ui5aEDoiBX72sR4J
icrNuxiMvsBbZjf0xAifzLbnejYg8QpLsvJyLEQh5rsbZvLzYJA19yXGIrPsh5Lu
k1xnAIWfdrUT5+3/RbnhQ8Y+KNjeeiq3mTNcbd4r9lIkupz+83zEg8IUOzVcYpu5
CSdWntVRBqXgABRbiXZAqjNJNk3KD41QDA/L0O+Ig7pum6YOEUS39UpDGxNo+Hhf
0L9TiIiX0WCEIH7PfLr8B+Wcu4XdVE4ZEHnmFWeBQi4IrlYo0RRsYCjTQpuRaM4Z
GQrQ0nV1W0GdJe/IuQIwyoWE3nKv4xUh0OPA3VD+9lFleLMdwXEnVa5yS+CRh5n9
wx8iBt+KWf1oaIi+/nmGdeyH60anlQ/xd5AS6hvtES/hdYkW08ZkgNGVBAhzWgfA
doCrNIbNhSvYyfkK48yrREY9AW1TmWizbBSKQfwysAS7llaHrzPjS1QKFHDr8kJx
+MZgjLesoTl87/5gLwv8fhZ2NoOebg3xgUemXdWN1u2KsjX1+1BbQWtYd7Mq9cdt
5SJo70qghMAb1Yq49qfONRX1rcA94YNocfMEBDpzibw4SWW02SmlVieKhzo1c46s
mBGsGQNrRdrUkSFhhNX3
=rGeu
-----END PGP SIGNATURE-----

--5KQCGTSHefEHmhHWbhXnsqUeMgPTRsNqc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
