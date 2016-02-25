Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id DCAA46B0253
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 13:32:56 -0500 (EST)
Received: by mail-qk0-f169.google.com with SMTP id s5so22891034qkd.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 10:32:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b107si9186488qge.55.2016.02.25.10.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 10:32:55 -0800 (PST)
Message-ID: <1456425170.15821.77.camel@redhat.com>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
From: Rik van Riel <riel@redhat.com>
Date: Thu, 25 Feb 2016 13:32:50 -0500
In-Reply-To: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-wfZLhNrFCToexneBZVpu"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--=-wfZLhNrFCToexneBZVpu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-02-25 at 17:12 +0000, Mel Gorman wrote:

> THP gives impressive gains in some cases but only if they are quickly
> available.=C2=A0=C2=A0We're not going to reach the point where they are
> completely
> free so lets take the costs out of the fast paths finally and defer
> the
> cost to kswapd, kcompactd and khugepaged where it belongs.
>=20
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

I agree with your conclusions, but with the caveat
that if we do not try to defragment memory for THP
at fault time, mlocked programs might not have any
opportunity at all to get transparent huge pages.

I wonder if we should consider mlock one of the slow
paths where we should try to actually take the time
to create THPs.

Also, we might consider doing THP collapse from the
NUMA page migration opportunistically, if there is a
free 2MB page available on the destination host.

Having said all that ...

Acked-by: Rik van Riel <riel@redhat.com>

--=C2=A0
All rights reversed

--=-wfZLhNrFCToexneBZVpu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJWz0jSAAoJEM553pKExN6DWfcIAKs0WkO1t2H7QgitHYjRFNde
cTMENRWwDaKu/usX+lPFHEw4dq9FGEN2U+LPaiP7FCkfYe3pLeoEoPnceX2p8zmI
KbhqX+3vvGyzdn2AXYNdy+GviY5L05Kl+Rkgwa+RLksCiEaDFA4jCBldxwqFkPF4
BqXTZGsHHNuGlZTWuLRkgNGnzTAobN0gaX83LP5TwKQbdTbje6cUanIXzwBpSphE
egxk1aehJ82qVXkslV8fYchgEm37pS0dvXf+4QVcpQ2LImNp0iHiX/cY2rjkwkdB
5eWGy4DeVDKw3CEubWLHfzT3y9Jb1B/qflTKMnClPobZzrqcZsKEcj3N635xurU=
=x30P
-----END PGP SIGNATURE-----

--=-wfZLhNrFCToexneBZVpu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
