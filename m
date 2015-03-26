Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id E39D16B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 23:37:00 -0400 (EDT)
Received: by igcau2 with SMTP id au2so119417149igc.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:37:00 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id u5si3918536icv.40.2015.03.25.20.37.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 20:37:00 -0700 (PDT)
Received: by igcau2 with SMTP id au2so6302100igc.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:37:00 -0700 (PDT)
Message-ID: <55137ED7.6000300@gmail.com>
Date: Wed, 25 Mar 2015 23:36:55 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com> <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org> <550A5FF8.90504@gmail.com> <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com> <550E6D9D.1060507@gmail.com> <5512E0C0.6060406@suse.cz> <55131F70.7020503@gmail.com> <alpine.DEB.2.10.1503251710400.31453@chino.kir.corp.google.com> <551351CA.3090803@gmail.com> <alpine.DEB.2.10.1503251914260.16714@chino.kir.corp.google.com> <55137C06.9020608@gmail.com>
In-Reply-To: <55137C06.9020608@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="fkRdFvaECUfOwRNlDWWPUfxapEi6OUESe"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aliaksey Kandratsenka <alkondratenko@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fkRdFvaECUfOwRNlDWWPUfxapEi6OUESe
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

jemalloc doesn't really use free lists or sbrk for user allocations much
at all: thread caches are arrays of pointers (easier to flush and no
need to deref stale memory), red-black trees manage chunks and runs
within chunks, and runs use bitmaps. It can use sbrk as an alternate
source of chunks, but it defaults to using mmap and there's no real
advantage to switching it.

THP currently seems to be designed around the assumption that all
userspace allocators are variants of dlmalloc...


--fkRdFvaECUfOwRNlDWWPUfxapEi6OUESe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVE37XAAoJEPnnEuWa9fIqWGsQAIcv47DkrYMIHMjcI76ZgTlJ
xIPQp54tN6/irfJmlZVR3YYxpfL/PkjRmnsmTuiXgD/ngrl3xLi2j0yGObiYIeoh
iZU4V/YOt6a5Qe6cmonsIvCCvUL3glqp94F8k+JoSBr8GTvykzkqKXvstzJXZkvT
xBOYmFfO7GvQlJDpwX6P3bj/Yq3ldIkiq/UiGo8w8DTcsUdqlNYjU9JZlhQwiukF
J5cysbA3YuuxS6ZFrQdyAI1p30PIIKMTIXjluVWNsybREPtsapvEaWiotEdE/DFU
fACW0m6EWL1yq0uDi1BWXESrufEiIB3jXYB4TFTmynuRf1LToXZm1sqyk+7OUz5+
Pjg1L+hEv08nLVcDduJlSJzRcp2uV4wLKAWd369aWafmQrTsAViREemKLzaV7XJV
4ec6+z+8oA293uKA585jMElR/SHelku3yAiPoCiw1hxFZHKBIHvDdGFQaXaxgdsr
YZ9ViCiUSkNAyNGF15SY9LkVWqzF0rl1viX2jxSvBn0JUY4UK4AIplq75MmH28Y6
XbZpNslIIDUKTJRI9VluA9Yw/Rp5OJKjmsCq/Rzr4skQGVRNsz6UrLeENTgbJLAy
Q7aQ7X/aGqHbwCbhPH6DNBDOwv7TWTvfZl6gyDpa/klAmluaPntBu1x5u716zLVF
rEpOzWMmvkW2Ha5slZIw
=SD8J
-----END PGP SIGNATURE-----

--fkRdFvaECUfOwRNlDWWPUfxapEi6OUESe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
