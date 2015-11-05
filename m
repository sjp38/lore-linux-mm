Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA4682F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 15:14:09 -0500 (EST)
Received: by qgeb1 with SMTP id b1so22893420qge.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 12:14:08 -0800 (PST)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com. [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id 20si5908664qhw.6.2015.11.05.12.14.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 12:14:08 -0800 (PST)
Received: by qgeb1 with SMTP id b1so22893192qge.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 12:14:08 -0800 (PST)
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
 <CALCETrUuNs=26UQtkU88cKPomx_Bik9mbgUUF9q7Nmh1pQJ4qg@mail.gmail.com>
 <56399CA5.8090101@gmail.com>
 <CALCETrU5P-mmjf+8QuS3-pm__R02j2nnRc5B1gQkeC013XWNvA@mail.gmail.com>
 <563A813B.9080903@gmail.com> <20151105181726.GA63566@kernel.org>
 <563BB855.6020304@gmail.com>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <563BB88D.7060606@gmail.com>
Date: Thu, 5 Nov 2015 15:14:05 -0500
MIME-Version: 1.0
In-Reply-To: <563BB855.6020304@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="vp9n9XES77FArX27xHt834GedEwaqaWxq"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux API <linux-api@vger.kernel.org>, Jason Evans <je@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, yalin wang <yalin.wang2010@gmail.com>, Mel Gorman <mgorman@suse.de>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--vp9n9XES77FArX27xHt834GedEwaqaWxq
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

> active:clean

active:dirty*, sigh.


--vp9n9XES77FArX27xHt834GedEwaqaWxq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWO7iOAAoJEPnnEuWa9fIqMv8QAIzD2J9PzxJpfXpm5AhyoC+v
alYaKROuo4IZ7m3bjAznsWWX5/A1NmfGzto6XA7iNPdRXr+7qX/uFE9ljPgqw+0e
Na5ngKHOtxmV1SEt2ZnibVM88TflroEQLOSEKRngTB9aFN0XbDRIb88CYfD4d+CG
hLnOP1QSc/7EqjfFwy4VD8FL23f4F2ki+sYhtDsb2KN7apiOGNmrsVKNf4kpuoyi
CAokM0JeRoJZb2WdGrBp4A7QOGdSbmWNqJlchvwrtB9Lyl01xulIeUTpPxjXUs+5
/KPHKRxQvBzwq4rKuSdjfHKslaayf2cg/Ecp8baZyzpwmjpgibxEBNhoL1Fw/7K+
eZxgG+OL4n0NL3z90i14JDtf4pgmdD3uRtcpaz3j5IU+SSHswBCQems0YwARQCHc
tdE5QzgEvdNuFQgJq209ZaAWkZZoiNw4Gug1jNhBG+haGxxOzFki+KQB/OIreTPT
vWphmc5KaL+0/Gj26lcJyiBShsqBDfpjGWUc/Gng63JQMkNnqP0ziDDGMBBO8Fdr
xBm07i0ZChi1TRQIlQfUHVhyzFHxjBFmgNpqSyTGGHs90IMgtrr1+8hEvDkQI26E
kmdMu2DB76+33mIDpLLu4C3gMulTVwcp1QVZBilTgU0z2yHHq9x9DF8SBqxtLlM6
AYDag0KsZsSR7hBF/3bK
=5Y66
-----END PGP SIGNATURE-----

--vp9n9XES77FArX27xHt834GedEwaqaWxq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
