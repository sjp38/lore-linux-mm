Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 381126B0266
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 20:38:22 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id w75so61535197qkb.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 17:38:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x129si3341881qkd.113.2016.09.22.17.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 17:38:20 -0700 (PDT)
Message-ID: <1474591086.17726.1.camel@redhat.com>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
From: Rik van Riel <riel@redhat.com>
Date: Thu, 22 Sep 2016 20:38:06 -0400
In-Reply-To: <20160922225608.GA3898@kernel.org>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	 <20160922225608.GA3898@kernel.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-5Prtq+7z/KKz1nxKKF5G"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>, "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>


--=-5Prtq+7z/KKz1nxKKF5G
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-09-22 at 15:56 -0700, Shaohua Li wrote:
> On Wed, Sep 07, 2016 at 09:45:59AM -0700, Huang, Ying wrote:
> >=C2=A0
> > - It will help the memory fragmentation, especially when the THP is
> > =C2=A0 heavily used by the applications.=C2=A0=C2=A0The 2M continuous p=
ages will
> > be
> > =C2=A0 free up after THP swapping out.
>=20
> So this is impossible without THP swapin. While 2M swapout makes a
> lot of
> sense, I doubt 2M swapin is really useful. What kind of application
> is
> 'optimized' to do sequential memory access?

I suspect a lot of this will depend on the ratio of storage
speed to CPU & RAM speed.

When swapping to a spinning disk, it makes sense to avoid
extra memory use on swapin, and work in 4kB blocks.

When swapping to NVRAM, it makes sense to use 2MB blocks,
because that storage can handle data faster than we can
manage 4kB pages in the VM.

--=20
All Rights Reversed.
--=-5Prtq+7z/KKz1nxKKF5G
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJX5HlvAAoJEM553pKExN6DqU8H/jg/a+kkz6Gpj7jWmXdlG2AM
wbTc9hajoCZbfxSTbQIDqDvqRw5r8g/Kh+17xq7hXMvPJEmhq4OmPqVFWN2iKMsn
nVdqqqcYMQzgx8MEMtxuTwy4fuUANwZl/ZbP8j41RCIkBOB47mrwJE3hDupd3Hue
/XV1dHAc9Dp2T9vAa7uef9ohe3J6UgtssUlI9cqaAVhEajQ22/6b3zk2JMcCsawf
Us5ySt6xWg7e8I6NHDwRdQX9uQ0dD0nNc5fwWIt98lBJ6UpQG56zje83DImMPJR8
Aon2RQ08AffebLxftB2lvshizWIRNBbZ/JJ6ihO1FqllupVEF2WLjEuwOstW2Qc=
=1pH3
-----END PGP SIGNATURE-----

--=-5Prtq+7z/KKz1nxKKF5G--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
