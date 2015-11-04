Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB136B0254
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 00:54:19 -0500 (EST)
Received: by iodd200 with SMTP id d200so43452193iod.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 21:54:18 -0800 (PST)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id n7si17137943ige.77.2015.11.03.21.54.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 21:54:18 -0800 (PST)
Received: by ioll68 with SMTP id l68so43897169iol.3
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 21:54:18 -0800 (PST)
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
 <CALCETrUuNs=26UQtkU88cKPomx_Bik9mbgUUF9q7Nmh1pQJ4qg@mail.gmail.com>
 <56399CA5.8090101@gmail.com>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <56399D66.5010606@gmail.com>
Date: Wed, 4 Nov 2015 00:53:42 -0500
MIME-Version: 1.0
In-Reply-To: <56399CA5.8090101@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="cUQ8j9QwPBRa7ColOaP5oLioCC5dAas0V"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux API <linux-api@vger.kernel.org>, Jason Evans <je@fb.com>, Shaohua Li <shli@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, yalin.wang2010@gmail.com, Mel Gorman <mgorman@suse.de>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cUQ8j9QwPBRa7ColOaP5oLioCC5dAas0V
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> In the common case it will be passed many pages by the allocator. There=

> will still be a layer of purging logic on top of MADV_FREE but it can b=
e
> much thinner than the current workarounds for MADV_DONTNEED. So the
> allocator would still be coalescing dirty ranges and only purging when
> the ratio of dirty:clean pages rises above some threshold. It would be
> able to weight the largest ranges for purging first rather than logic
> based on stuff like aging as is used for MADV_DONTNEED.

I would expect that jemalloc would just start putting the dirty ranges
into the usual pair of red-black trees (with coalescing) and then doing
purging starting from the largest spans to get back down below whatever
dirty:clean ratio it's trying to keep. Right now, it has all lots of
other logic to deal with this since each MADV_DONTNEED call results in
lots of zeroing and then page faults.


--cUQ8j9QwPBRa7ColOaP5oLioCC5dAas0V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWOZ1mAAoJEPnnEuWa9fIqqlAQAJLjzAeM7JTdDiC4x1MD5iT9
HLoKkhjx3h7vYNjJ7DX67+AHchAsEVGqi7mmEi2WNKa0Ia9nihJnOJ5yN5QLVFNk
nncn0tRocYeBjiyGnXENsNf3BmleemmQ+A9y/1j2INWB2hFTtv8H4HXglwiFNT1w
BHO10/mUgeHUgkLjR3Ev30Pz2/6EdNHDdccQafdBdYn4DMU3i2WRHk9LeqcpkY1B
oWnPl+AL29FkwbFbHRwBWGdg905NckpG23Res4+NgCsDh2dn+qZJEeDyh0mppZQU
HgIwmyC1YOx+5Gtxqj4VYtdmyfVDboo2ho0IEcmUL0Q/8xixnVUn15oVqt7ea87Q
TFD5ynLQs4Rsi2HTwVLGkZOlPWZZOsmcDYVsBsxK5ft1sLkzDqIO5fD3zNop7XyV
A3x1LHzGNe24fV2sJXUf1kaPO2cj/rpJVKkmAu4Dnx7+L3hI7Exk2TNWLyi5dJni
0rAVECfCDWx52I9+txdQ4tujTLBfpOXns1FEIAw2bi+K7XCGhs+wilj71us42Pg2
rTOnl6hB8R6nOPHuLUmEiTPzlhH5hdMA9ulYLLlyThVXTD4fVHIO3KqNB1I6H2Lz
YnXdSCv+3h4oItr/DK5Hc2Xcj8KRCKP7aXl10Jv2xTFcFs6aOlyxV28Ma8ipZen5
x0wElmKMJVChjJm3JSUd
=sB2E
-----END PGP SIGNATURE-----

--cUQ8j9QwPBRa7ColOaP5oLioCC5dAas0V--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
