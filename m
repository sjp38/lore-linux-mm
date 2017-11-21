Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D89D26B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:35:53 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id p19so7907338qke.5
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:35:53 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0107.outbound.protection.outlook.com. [104.47.38.107])
        by mx.google.com with ESMTPS id x66si2359163qkg.333.2017.11.21.14.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 14:35:53 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of
 prep_transhuge_page()
Date: Tue, 21 Nov 2017 17:35:45 -0500
Message-ID: <73A54AD9-33E0-4C82-8C9F-6E1786ED6132@cs.rutgers.edu>
In-Reply-To: <20171121141213.89db86bfbd75c22fc0209990@linux-foundation.org>
References: <20171121021855.50525-1-zi.yan@sent.com>
 <20171121141213.89db86bfbd75c22fc0209990@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_819C1EF7-A389-4F67-8072-1326F8F2CD40_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Reale <ar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_819C1EF7-A389-4F67-8072-1326F8F2CD40_=
Content-Type: text/plain; charset=utf-8; markup=markdown
Content-Transfer-Encoding: quoted-printable

On 21 Nov 2017, at 17:12, Andrew Morton wrote:

> On Mon, 20 Nov 2017 21:18:55 -0500 Zi Yan <zi.yan@sent.com> wrote:
>
>> In [1], Andrea reported that during memory hotplug/hot remove
>> prep_transhuge_page() is called incorrectly on non-THP pages for
>> migration, when THP is on but THP migration is not enabled.
>> This leads to a bad state of target pages for migration.
>>
>> This patch fixes it by only calling prep_transhuge_page() when we are
>> certain that the target page is THP.
>
> What are the user-visible effects of the bug?

By inspecting the code, if called on a non-THP, prep_transhuge_page() wil=
l
1) change the value of the mapping of (page + 2), since it is used for TH=
P deferred list;
2) change the lru value of (page + 1), since it is used for THP=E2=80=99s=
 dtor.

Both can lead to data corruption of these two pages.

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_819C1EF7-A389-4F67-8072-1326F8F2CD40_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAloUqkEWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzAyhB/4vCvTpuOhBfIZDM4XJ+NMYvtW8
UgIOaah2kd2dnfTdBcTFR1xrLHpdlcyPWrMbn/JYKQ4+qdBzb9aEBIx1jyF7Ncly
GodIw9ahPgAorSmrDaD1rlhbeAlrMkBVz8UQ/YQVyOXn3Ps7xx2Hfjixu2JhJEaX
tEr2JpF8/fSz9GbzoPztdG67LYqvBsrbrL8UeS0xTzI34QUq38omXN8nyo7ilkTv
j/XZUYc0jjrOa5L+SCnACQZrlJNrS981AUPCcQgybIP9hJ61A+mku+0wvFaU256s
Hgg1hqntwbYWEGsj/JLFDMmvu1xTfsO2XHzCFphho2piXMAXSD6kcSNvAWfo
=R6Og
-----END PGP SIGNATURE-----

--=_MailMate_819C1EF7-A389-4F67-8072-1326F8F2CD40_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
