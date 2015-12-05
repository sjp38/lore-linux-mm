Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id F2DA86B0257
	for <linux-mm@kvack.org>; Sat,  5 Dec 2015 10:52:04 -0500 (EST)
Received: by qgec40 with SMTP id c40so112988534qge.2
        for <linux-mm@kvack.org>; Sat, 05 Dec 2015 07:52:04 -0800 (PST)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id 11si15713774qhx.41.2015.12.05.07.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Dec 2015 07:52:03 -0800 (PST)
Received: by qgeb1 with SMTP id b1so114090687qge.1
        for <linux-mm@kvack.org>; Sat, 05 Dec 2015 07:52:03 -0800 (PST)
Subject: Re: [PATCH v2 00/13] MADV_FREE support
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <20151205111042.GA11598@amd>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <5663081E.4010205@gmail.com>
Date: Sat, 5 Dec 2015 10:51:58 -0500
MIME-Version: 1.0
In-Reply-To: <20151205111042.GA11598@amd>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="25AEtqoWBXCvAxgbRSFnbrHf3lJq2GSlb"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--25AEtqoWBXCvAxgbRSFnbrHf3lJq2GSlb
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/12/15 06:10 AM, Pavel Machek wrote:
> On Wed 2015-11-04 10:25:54, Minchan Kim wrote:
>> MADV_FREE is on linux-next so long time. The reason was two, I think.
>>
>> 1. MADV_FREE code on reclaim path was really mess.
>=20
> Could you explain what MADV_FREE does?
>=20
> Comment in code says 'free the page only when there's memory
> pressure'. So I mark my caches MADV_FREE, no memory pressure, I can
> keep using it? And if there's memory pressure, what happens? I get
> zeros? SIGSEGV?

You get zeroes. It's not designed for that use case right now. It's for
malloc implementations to use internally. There would need to be a new
feature like MADV_FREE_UNDO for it to be usable for caches and it may
make more sense for that to be a separate feature entirely, i.e. have a
different flag for marking too (not sure) since it wouldn't need to
worry about whether stuff is touched.


--25AEtqoWBXCvAxgbRSFnbrHf3lJq2GSlb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWYwgeAAoJEPnnEuWa9fIqgHIP/jTlp7FHHc0W2g6+GR5Httb2
2ORoNvgw05Ry1iOpPNIYOJJpUBz++nE6tDC57amsOLsV1/CKxw/kZDs+zSEeAIyR
yQRIlG46pVA5nTmtpgBTGJX7ryD9BvDsoZKsWqkRJjby6S2Iy/v7c9bSjpmJdDVp
4hxrAgdBKWoSxnkcIC4LTEVGr9KhPEDyVXCihGhW78gMHY5KdnF4mxPPfgGaRTmq
eths7pEK9aAEDB1mjXRNj1q7I/PV+2yNuwGl5Bgi1JuHVKx6fpjWH42C1CBdAxPD
8qEtaT18uJZcsO3yIp/J3caXLwYBNooQIFcDV/0HAYcGW1NjyJvoVvPdnXH+cVp2
ICBhOVMgRUVTQiAmxMXem5PS1nMMwTI3m1WmpShCNO0XI0kF5We4WhpeAt1wns+A
mmLF3A/9JpdYwVnF4m7Sfj0lahSyvO+XJMJObtq5YwiAps/Cg91xC43rTe4n4TpK
rhG0stTS/RlW6/vJYcF7K5eH4dzm3xPCOY1lOKG4xlfkDalO+rLfVz/CuUjDbDCK
4ut8JyO5eq9Wx3bG1h3/pHPrpgQOcrr7lNhrv+6259/dkzq5HQ5hl70bl8r1yZzJ
2EX35OxYYVrwIJVI8kovg9oyECXR4xAmz/KygYVCotJ4/0NNd/1792XCqyYvPvJ8
EL+l2snIELktLOqS2NSO
=FiDs
-----END PGP SIGNATURE-----

--25AEtqoWBXCvAxgbRSFnbrHf3lJq2GSlb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
