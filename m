Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 81E296B0038
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 04:07:08 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so11958252pac.4
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 01:07:08 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id a16si10170827pdj.274.2014.07.29.01.07.06
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 01:07:07 -0700 (PDT)
From: "Joonsoo Kim" <iamjoonsoo.kim@lge.com>
References: <dsqnq2i1mer1r7kpvuflt0k9.1406214301636@email.android.com>
In-Reply-To: <dsqnq2i1mer1r7kpvuflt0k9.1406214301636@email.android.com>
Subject: RE: [linux-3.10.17] Could not allocate memory from free CMA areas
Date: Tue, 29 Jul 2014 17:06:59 +0900
Message-ID: <010401cfab04$1536b740$3fa425c0$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'pintu_agarwal' <pintu_agarwal@yahoo.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, ritesh.list@gmail.com
Cc: pintu.k@outlook.com, pintu.k@samsung.com, vishu_1385@yahoo.com, m.szyprowski@samsung.com, mina86@mina86.com, ngupta@vflare.org, iqbalblr@gmail.com



From: pintu_agarwal [mailto:pintu_agarwal@yahoo.com]=20
Sent: Friday, July 25, 2014 12:15 AM
To: PINTU KUMAR; linux-mm@kvack.org; =
linux-arm-kernel@lists.infradead.org; linaro-mm-sig@lists.linaro.org; =
iamjoonsoo.kim@lge.com; ritesh.list@gmail.com
Cc: pintu.k@outlook.com; pintu.k@samsung.com; vishu_1385@yahoo.com; =
m.szyprowski@samsung.com; mina86@mina86.com; ngupta@vflare.org; =
iqbalblr@gmail.com
Subject: RE: [linux-3.10.17] Could not allocate memory from free CMA =
areas

Dear joonsoo kim,

> I have your patches for: Aggressively allocate memory from cma ....
> We are facing almost similar problem here.
> If any of your patches still working for you please let us know here.
> I would like to try those approach.


Hello,

I stopped to implement it, because there are other bugs on CMA related =
codes.
Although aggressively allocate... doesn't have bugs itself, it enlarges
existing freepage counting bugs significantly so I'm first trying to fix
those bugs. See the below link.

https://lkml.org/lkml/2014/7/4/79

I will restart to implement aggressively... after fixing these bugs.

If you have interest on next version of aggressively allocate..., see =
the
following link.

https://github.com/JoonsooKim/linux/tree/cma-fix-up-v3.0-next-20140625

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
