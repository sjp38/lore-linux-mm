Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15DA96B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 22:32:39 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p53so125127005qtp.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 19:32:39 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id y190si10440152qke.276.2016.09.29.19.32.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 19:32:37 -0700 (PDT)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [PATCH v1 00/12] THP migration support
Date: Thu, 29 Sep 2016 22:32:36 -0400
Message-ID: <4F505AB2-9A71-4B89-8C93-83AB161A6DEA@sent.com>
In-Reply-To: <20160929082529.GA8389@hori1.linux.bs1.fc.nec.co.jp>
References: <20160926152234.14809-1-zi.yan@sent.com>
 <A0AA1E30-A897-4A48-9972-9BE1813AA57C@sent.com>
 <20160929082529.GA8389@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_802E6A38-DE76-4CB7-8818-60D8DA061D09_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_802E6A38-DE76-4CB7-8818-60D8DA061D09_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

>
> Thanks for helping,

:)

>
> I think that you seem to do some testing with these patches on powerpc,=

> which shows that thp migration can be enabled relatively easily for
> non-x86_64. This is a good news to me.

Right. I did some THP migration tests on both x86_64 and IBM ppc64.

You can use the code here to test the THP migration,
and compare the migration time between 512 base pages and 1 THP.
https://github.com/x-y-z/thp-migration-bench

NUMA (or fake NUMA) setup and libnuma are needed. Since it simply tries t=
o
migrate pages from node 0 to node 1.

make bench should give you the result like:

THP Migration
Total time: 676.870346 us
Test successful.
-------------------
Base Page Migration
Total time: 2340.078354 us
Test successful.

>
> And I apology for my slow development over this patchset.
> My previous post was about 5 months ago, and I've not done ver.2 due to=

> many interruptions. Someone also privately asked me about the progress
> of this work, so I promised ver.2 will be posted in a few weeks.
> Your patch 12/12 will come with it.

Looking forward to it. :)

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_802E6A38-DE76-4CB7-8818-60D8DA061D09_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJX7c7EAAoJEEGLLxGcTqbMaYAIAKPmFm3m4yWPHnM9FGNYxLVa
/6NZML1zguFUvRR95YStSqqBGZmlh4OC7M0zR8ttLoB7LgZ5lPoTRWrQIZUpUVX4
MRN/nrx87WRNU/fQtP0baSwgf6ka97kDAYKnsF+FZEi9r9rnh+Il/1j9hr0gRKMp
WxioBI+SB85bWP+NDTFgWaG37YGAa2qsg7Zeb5RqJqb1mZsawgw4fyIlIHfVkT0c
e4Oqev1yFYtc6PQe2sZovv1/rPSn2R091UeIjwNkC2ZTkvQz0fZVQtGcUVi9N4is
5+wE5uIXKdlU31CM6liVyvLBw5QwvJ4qnYg+vX46DfXr/4/XVCrcia+HRt7L6ZY=
=2FKZ
-----END PGP SIGNATURE-----

--=_MailMate_802E6A38-DE76-4CB7-8818-60D8DA061D09_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
