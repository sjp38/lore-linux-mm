Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 29CE46B025D
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 00:21:37 -0500 (EST)
Received: by iofh3 with SMTP id h3so55237505iof.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 21:21:37 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id n7si27623429ige.77.2015.11.11.21.21.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 21:21:36 -0800 (PST)
Received: by igcph11 with SMTP id ph11so86859121igc.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 21:21:36 -0800 (PST)
Subject: Re: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
 <1447302793-5376-2-git-send-email-minchan@kernel.org>
 <CALCETrWA6aZC_3LPM3niN+2HFjGEm_65m9hiEdpBtEZMn0JhwQ@mail.gmail.com>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <564421DA.9060809@gmail.com>
Date: Thu, 12 Nov 2015 00:21:30 -0500
MIME-Version: 1.0
In-Reply-To: <CALCETrWA6aZC_3LPM3niN+2HFjGEm_65m9hiEdpBtEZMn0JhwQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Se18ghPEcLHSaaDiqlU3mG3BW3BwKGCDu"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin wang <yalin.wang2010@gmail.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Se18ghPEcLHSaaDiqlU3mG3BW3BwKGCDu
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> I also think that the kernel should commit to either zeroing the page
> or leaving it unchanged in response to MADV_FREE (even if the decision
> of which to do is made later on).  I think that your patch series does
> this, but only after a few of the patches are applied (the swap entry
> freeing), and I think that it should be a real guaranteed part of the
> semantics and maybe have a test case.

This would be a good thing to test because it would be required to add
MADV_FREE_UNDO down the road. It would mean the same semantics as the
MEM_RESET and MEM_RESET_UNDO features on Windows, and there's probably
value in that for the sake of migrating existing software too.

For one example, it could be dropped into Firefox:

https://dxr.mozilla.org/mozilla-central/source/memory/volatile/VolatileBu=
fferWindows.cpp

And in Chromium:

https://code.google.com/p/chromium/codesearch#chromium/src/base/memory/di=
scardable_shared_memory.cc

Worth noting that both also support the API for pinning/unpinning that's
used by Android's ashmem too. Linux really needs a feature like this for
caches. Firefox simply doesn't drop the memory at all on Linux right now:=


https://dxr.mozilla.org/mozilla-central/source/memory/volatile/VolatileBu=
fferFallback.cpp

(Lock =3D=3D pin, Unlock =3D=3D unpin)

For reference:

https://msdn.microsoft.com/en-us/library/windows/desktop/aa366887(v=3Dvs.=
85).aspx


--Se18ghPEcLHSaaDiqlU3mG3BW3BwKGCDu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWRCHeAAoJEPnnEuWa9fIqwfoP/i3+X7dS4t4/swOr7e4brAqt
ZhBVZcywBqWLWfrDka8JUtM8lFW5c3AlYBVXsPEXJytuGdz9lm8Ct+gJTJrzQ1mg
DF1mAq6MD+DWgI5094kQJvERR1MRfR5KyH9kGQlEOSsMIWlG2uyIMmA9oCZINDSZ
0OB7fEAtXe/DLSVtisIvH9Uybeem6MHnaKJmHrtvIiKuVn9hnfvjG7KByIc+jvBi
w+zyXQSkmgzSFdGexyANCdfdqvZqVAKKO18HQ//n+9nPzPNmC+9sfUFByUWGocJz
bGNxvWzfEIZJC/Xu+kBgq/mZHDttPMnF18zO2MWnMH4op7m3YvCt4GPXzX1MmDHa
IpAlqp+KOmEZ8kSuHQ3joqcx/IB4n+amoF6sUOT2Qw6HPVhSHg0yLhovB4D4vnGh
2OdLCqNsH8viYHty4hLgHV9M+QWMthE+sSENM3T08/kbCfnzcypkOx5d5D0iNAc6
qgpFY6O/2MYmqC0VkX41QEuhopB18PdYa9n56Yo3nVnbbVEWqEpeSWHRCZ6j6Oib
ojzxVnDQpDJzm85HtA2rVnRqk9Ryis2168cbS7ZoOXLXjPUhViVHNyy5fMCowTcg
pEdz7Baaiq8R0Iuo/DZCKwtjGM/ocePEmguKM8i31pwCKXqf+TPBSBS1VYIpUJf7
z8BjttnxfZThV8goqQDy
=l8YU
-----END PGP SIGNATURE-----

--Se18ghPEcLHSaaDiqlU3mG3BW3BwKGCDu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
