Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id E561A82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 18:50:33 -0500 (EST)
Received: by iodd200 with SMTP id d200so72273314iod.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 15:50:33 -0800 (PST)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id gb2si4143743igd.38.2015.11.04.15.50.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 15:50:33 -0800 (PST)
Received: by igbhv6 with SMTP id hv6so47789323igb.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 15:50:33 -0800 (PST)
Subject: Re: [PATCH 5/8] mm: move lazily freed pages to inactive list
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-6-git-send-email-minchan@kernel.org>
 <20151104205504.GA9927@cmpxchg.org> <563A7D21.6040505@gmail.com>
 <20151104225527.GA25941@cmpxchg.org> <563A9681.3070102@gmail.com>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <563A99A2.6010708@gmail.com>
Date: Wed, 4 Nov 2015 18:49:54 -0500
MIME-Version: 1.0
In-Reply-To: <563A9681.3070102@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="k0kDwtgODIEgNHu0OeacGeSBTwiQV7a4u"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--k0kDwtgODIEgNHu0OeacGeSBTwiQV7a4u
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

> From a user perspective, it doesn't depend on swap. It's just slower
> without swap because it does what MADV_DONTNEED does. The current
> implementation can be dropped in where MADV_DONTNEED was previously use=
d.

It just wouldn't replace existing layers of purging logic until that
edge case is fixed and it gains better THP integration.

It's already a very useful API with significant performance wins over
MADV_DONTNEED, so it will be useful. The only risk involved in landing
it is that a better feature might come along. Worst case scenario being
that the kernel ends up with a synonym for MADV_DONTNEED (but I think
there will still be a use case for this even if a pinning/unpinning API
existed, as this is more precise).


--k0kDwtgODIEgNHu0OeacGeSBTwiQV7a4u
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWOpmiAAoJEPnnEuWa9fIqDPQP/R9XV3XxkHqRG4OYJrAtg1WB
FOHhev+ws5lP+6P/4Da6BS9OFPC8Ok7P2tCf/9b3p2nEMmN8vVmuKdTToZpUfTzK
n5//uXoUey5+S1OlDD7Vs9StkqdBG3mhz7eISzRn0TTv8MMeXkvk4n90fzjrIQF1
iEnUvOTrB1SU8U+DvTGuHwkfHN5WWFBJjnIFRqzADHBVQoXS9MRC0QZM5SaKF5Ms
j72DJVwpUQUWVeMhtuTtyehyCOp1mYTLoMlII8z1E/sFxZ9Bry/WG4iCIWNPfDxb
sQVqBWk2v80LF7Fo3bA+YuM6D+ZqSFULec+WUpq6s0ZESiFAcb3kJlriwocGuHdF
A16h+ZKQIXIdsUD5KbnxfsK0OiSH7/PE+GCpe8OhCOw5yH5VVePLcxBJ0MCXAJIW
mOIuYNlgadl2Pgh2YiXT1l9A8moICZzAWwUnjjvWdPow2JtHEDsAV2UdT1jOuYCb
EQsiiMxy2FNagHqAu5cWnSrgDatQPW5CY4lqngD9RY8hX+/RxYZ2Yxmg7R1/Tg6P
rsVFjrWMkw4KqdSIBberOEKYfiRcpU/OZ6/mPmRf2gokDQA7DjCr1tQOq85d1K7O
nrFN0nhI95EnK1rX8sYpYy39D/6ZfIU9UjLiLKNo4qq2z4V4juMNYH92hjra92Qn
WBbxJnB1JR6DjLNm0eiW
=mmlT
-----END PGP SIGNATURE-----

--k0kDwtgODIEgNHu0OeacGeSBTwiQV7a4u--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
