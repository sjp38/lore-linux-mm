Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4516B0255
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 01:05:27 -0500 (EST)
Received: by igdg1 with SMTP id g1so97785339igd.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 22:05:27 -0800 (PST)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id l142si1067233ioe.160.2015.11.03.22.05.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 22:05:27 -0800 (PST)
Received: by ioll68 with SMTP id l68so44103708iol.3
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 22:05:27 -0800 (PST)
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
 <CALCETrUuNs=26UQtkU88cKPomx_Bik9mbgUUF9q7Nmh1pQJ4qg@mail.gmail.com>
 <56399CA5.8090101@gmail.com> <56399D66.5010606@gmail.com>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <56399FFD.1050302@gmail.com>
Date: Wed, 4 Nov 2015 01:04:45 -0500
MIME-Version: 1.0
In-Reply-To: <56399D66.5010606@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="9mwiVDRwihtmkUwV9X70biccg5OpnXm2c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux API <linux-api@vger.kernel.org>, Jason Evans <je@fb.com>, Shaohua Li <shli@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, yalin.wang2010@gmail.com, Mel Gorman <mgorman@suse.de>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9mwiVDRwihtmkUwV9X70biccg5OpnXm2c
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/11/15 12:53 AM, Daniel Micay wrote:
>> In the common case it will be passed many pages by the allocator. Ther=
e
>> will still be a layer of purging logic on top of MADV_FREE but it can =
be
>> much thinner than the current workarounds for MADV_DONTNEED. So the
>> allocator would still be coalescing dirty ranges and only purging when=

>> the ratio of dirty:clean pages rises above some threshold. It would be=

>> able to weight the largest ranges for purging first rather than logic
>> based on stuff like aging as is used for MADV_DONTNEED.
>=20
> I would expect that jemalloc would just start putting the dirty ranges
> into the usual pair of red-black trees (with coalescing) and then doing=

> purging starting from the largest spans to get back down below whatever=

> dirty:clean ratio it's trying to keep. Right now, it has all lots of
> other logic to deal with this since each MADV_DONTNEED call results in
> lots of zeroing and then page faults.

Er, I mean dirty:active (i.e. ratio of unpurged, dirty pages to ones
that are handed out as allocations, which is kept at something like
1:8). A high constant cost in the madvise call but quick handling of
each page means that allocators need to be more aggressive with purging
more than they strictly need to in one go. For example, it might need to
purge 2M to meet the ratio but it could have a contiguous span of 32M of
dirty pages. If the cost per page is low enough, it could just do the
entire range.


--9mwiVDRwihtmkUwV9X70biccg5OpnXm2c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWOZ/9AAoJEPnnEuWa9fIqyRsP/ApuxErM7bPshCha4gdN1S75
TMXYV0q8K9MqUm5lK78cLTJNQUFM1CrFP8DiWHinL5322XqW/nEmbzWTSrQMBTdc
vv6kt5twjJ+vPB5YpOFqPNpDVc6YNiMWlVzwqDJf8FoumULa1JtMQOpQDYVIIsHj
DLr4A6otsEUaoZ0/sszJMJDc4hdU+gy05tvSihorOTn+ZwS/vteZhcANXtsNlt7f
lYcf8LsUrWDwwgHAeuz5ghcvstw5pd9DmhmoAz7GykCTWG44toG0FjTYhyH8/5Vu
fKZ9A+pgmSa8xrhVs6rrLSY0zEPzg0S9nJixaeXKEh5czQAj0kn5cCHqoKIpvtmj
0PWPX+LgSyankBK85nS+8va7d3uRk9ui3Sh9TwRhMYAoN+nJl9mwO+zxP22X60NR
mPyrEo/HM2bnzjHT1H8onBMJU0e5k341AmLgIsEEZi/K375ql8wN7TX+/oMBTpr6
5K0AEYFZdAOfmgb4sKXk2jKFZUL6odcqbI7cgEvnWw2js4F/RTORuWWkHFdtKQ9E
pxF07fjSwmR9dFCvOekJ34yq52LD8WXI/XEQ1sNv+eeI5drUfEu66Zns1rDgRoEm
SNoJYL7hhvcOsE+HM6EPjzHshfE0fwc1Dr3t1YxGFHBNnDTBDbJ3jR3Lvhl/RVt7
H+lXFWurH2FImUYb7Trv
=9mdk
-----END PGP SIGNATURE-----

--9mwiVDRwihtmkUwV9X70biccg5OpnXm2c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
