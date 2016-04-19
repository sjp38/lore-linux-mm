Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id 276576B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 10:33:28 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id t38so23004191qge.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 07:33:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z66si10676023qgz.65.2016.04.19.07.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 07:33:27 -0700 (PDT)
Subject: Re: [PATCHv7 00/29] THP-enabled tmpfs/shmem using compound pages
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
 <571565F0.9070203@linaro.org>
From: Jerome Marchand <jmarchan@redhat.com>
Message-ID: <571641AC.1050801@redhat.com>
Date: Tue, 19 Apr 2016 16:33:16 +0200
MIME-Version: 1.0
In-Reply-To: <571565F0.9070203@linaro.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="lG7h0XBx7BGwM6RPPqqMTam6PmfBDUROp"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lG7h0XBx7BGwM6RPPqqMTam6PmfBDUROp
Content-Type: multipart/mixed; boundary="tFIWlQ2XbKfjt9jg7DTP5upGXfvSjev4Q"
From: Jerome Marchand <jmarchan@redhat.com>
To: "Shi, Yang" <yang.shi@linaro.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>,
 Christoph Lameter <cl@gentwo.org>,
 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
 Sasha Levin <sasha.levin@oracle.com>,
 Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-fsdevel@vger.kernel.org
Message-ID: <571641AC.1050801@redhat.com>
Subject: Re: [PATCHv7 00/29] THP-enabled tmpfs/shmem using compound pages
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
 <571565F0.9070203@linaro.org>
In-Reply-To: <571565F0.9070203@linaro.org>

--tFIWlQ2XbKfjt9jg7DTP5upGXfvSjev4Q
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/19/2016 12:55 AM, Shi, Yang wrote:
> 2. I ran my THP test (generated a program with 4MB text section) on bot=
h
> x86-64 and ARM64 with yours and Hugh's patches (linux-next tree), I got=

> the program execution time reduced by ~12% on x86-64, it looks very
> impressive.
>=20
> But, on ARM64, there is just ~3% change, and sometimes huge tmpfs may
> show even worse data than non-hugepage.
>=20
> Both yours and Hugh's patches has the same behavior.
>=20
> Any idea?

Just a shot in the dark, but what page size do you use? If you use 4k
pages, then hugepage size should be the same as on x86 and a similar
behavior could be expected. Otherwise, hugepages would be too big to be
taken advantage of by your test program.

Jerome


--tFIWlQ2XbKfjt9jg7DTP5upGXfvSjev4Q--

--lG7h0XBx7BGwM6RPPqqMTam6PmfBDUROp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJXFkGsAAoJEHTzHJCtsuoCjhoIAJ0Z5EXVir7auplyT3xoqRHn
rDJCFgolGiThUHd+YUAXBDjqqc2LMVZFnoC9n05rKH7zcsD8BhUTP5z2ptIz0oFU
KH2UdFBEyoGBRC8gxczqHEEfNAcwasmABf4ofqDcB2hEJSOXLFlB4K5yo/hf5nQB
5vf1xTvr/g0mDvw1IkSDVWdKEQUpKGrEo7YyFoMFOWNS9P/7xjzQBL64n+7qRHjS
6Rbm8VGKiTkAhqIkWKiZaT/oBSqtmagzt8T+s4tddzPq99uOM6VmB15ogsgNAAvY
H/NMfnCb/nxFbWk2+SnVD6Vb/P9+8edN2e0ASu2oa3ItEwZTay4Y02NG7srPESE=
=uUfK
-----END PGP SIGNATURE-----

--lG7h0XBx7BGwM6RPPqqMTam6PmfBDUROp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
