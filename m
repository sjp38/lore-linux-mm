Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11B4CC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 23:23:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EA1E2189F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 23:23:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="POKycPna"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EA1E2189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08ADD8E0015; Wed, 24 Jul 2019 19:23:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 062B68E0002; Wed, 24 Jul 2019 19:23:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBBA58E0015; Wed, 24 Jul 2019 19:23:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD2CF8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:23:25 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id e66so29611481ybe.19
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:23:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=U/byz8o3kezigETW8hWUjg+JqkNm/y0Q4UHjAnDVaRI=;
        b=Dav262jCiBg8BWfHhACZE5U/AVUnBy9CY4bQ6gnX8pvdRtuM2aRP/wTrCZr8dkpvzZ
         /vzygisRWTBAhZe/wdDGY61SnFXR/XrEfzr6HdfcK7JN6+7F3BI29ubqUUPLxeKMMa/H
         tYfMS1G2MsW0J/uasUyFWPBGmzNm401uXGAKTPL9ykMv6ILhx/nexpo1qnDzzFtNvuz7
         gBTtcPuYOx3XPmmaMsv/RWik1OV8pSMCTnkLFgINm5/kPQizJ17cItZMVAxi6B7JW8OP
         5I0mPZBvT+rofkN7fjEAzQc3SKRkkn4WtKlJeBkD15OGR99GjHj7fib2q6m149KdLXEZ
         7B3Q==
X-Gm-Message-State: APjAAAWfy5mKtxV/kHLL/y+dakPoOaApgwyXcPYUy9bwMDh7GaLWE96B
	b0LvmrvWTePJ/ucK7YDawdJcs7zP8oNKnLsT9q48Qn/mFdCxUIXIrIUwLA3QxL/L8gX1QyaJ1ZN
	2qU2mK8mnuLTMCZPTXhlYNi4RM4RTwdX/xvdNsVnoqgDgbYjb3i9PRQwt1FfH4o1enQ==
X-Received: by 2002:a25:5986:: with SMTP id n128mr51959880ybb.301.1564010605371;
        Wed, 24 Jul 2019 16:23:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhknzfn71H38aLzT4m3TMfqPoAcl4zoqqoY1stgPILl/x8gFHRTfa2/eZLUE45aSuuXOI4
X-Received: by 2002:a25:5986:: with SMTP id n128mr51959852ybb.301.1564010604651;
        Wed, 24 Jul 2019 16:23:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564010604; cv=none;
        d=google.com; s=arc-20160816;
        b=VaPXI7NY0VfLxG0xpuqgyky14sXS7AeCAHQ6vrH3r7+PKGsZIo12SSv1oFiuc8ex05
         IrhTsUhcgPFvfgmrCLzdDx7/wNlTU04xhH7D/4ZLgWKJZo9Tg4VJ6n1yHTSD/rVRMKxm
         vM28dD8z3jqR9ndEf3Zt3CAQi0b+LmPBrEfL5Ll+H2eInW+PiIeIRUH5vL8GXdLy9vEs
         ctEXWHymH/jYr9zShC4hizquEyzg8g+08chexDr3SPVlCme7JEzjOmFwDSaHbuwNYtFj
         lISVR8DDvuCPNh2zDJJd+/6SFOeeFhkZ6eKcKZh31aKNATvXoKqB4Xo3oiAQEv5y62Q5
         mslg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=U/byz8o3kezigETW8hWUjg+JqkNm/y0Q4UHjAnDVaRI=;
        b=iXSsyxYiXc+X6iIq/sPdqOpCGHe+Q19BvYR3Mxp2aPA4ERxfM7i30rCR8KeFCAqc5A
         VbpCa2mgQCKT5krTE2bXZfPBIOGkuZV56bSGY/9o6BM8nhcamU5M+1WxCWXdEAfBu6j2
         VkMRBvBNWSJo/Ve3pnOKAiP7fUxEKLbIl8cDOKRKWjMJ/aezYlmg+q8WiXEMlG6PtpE4
         BqXhbT02+o9pGvL0duKUcw0lHPSG3GXFbc5t2pfOd5cWtPNYMI603gMz5BMWGd00miwM
         CqBsG+ISYkLhVheiNq1NunIdEsxcB2f8oGZQ/ZwNeftEViRwri9QsxRMnYIXNbVkBr1I
         fIcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=POKycPna;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id a199si18886122ywe.403.2019.07.24.16.23.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 16:23:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=POKycPna;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d38e8730000>; Wed, 24 Jul 2019 16:23:31 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 24 Jul 2019 16:23:23 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 24 Jul 2019 16:23:23 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 24 Jul
 2019 23:23:22 +0000
Subject: Re: [PATCH 00/12] block/bio, fs: convert put_page() to
 put_user_page*()
To: Christoph Hellwig <hch@infradead.org>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro
	<viro@zeniv.linux.org.uk>, Anna Schumaker <anna.schumaker@netapp.com>, "David
 S . Miller" <davem@davemloft.net>, Dominique Martinet
	<asmadeus@codewreck.org>, Eric Van Hensbergen <ericvh@gmail.com>, Jason
 Gunthorpe <jgg@ziepe.ca>, Jason Wang <jasowang@redhat.com>, Jens Axboe
	<axboe@kernel.dk>, Latchesar Ionkov <lucho@ionkov.net>, "Michael S . Tsirkin"
	<mst@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>, Trond Myklebust
	<trond.myklebust@hammerspace.com>, Christoph Hellwig <hch@lst.de>, Matthew
 Wilcox <willy@infradead.org>, <linux-mm@kvack.org>, LKML
	<linux-kernel@vger.kernel.org>, <ceph-devel@vger.kernel.org>,
	<kvm@vger.kernel.org>, <linux-block@vger.kernel.org>,
	<linux-cifs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<netdev@vger.kernel.org>, <samba-technical@lists.samba.org>,
	<v9fs-developer@lists.sourceforge.net>,
	<virtualization@lists.linux-foundation.org>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
 <20190724061750.GA19397@infradead.org>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <17f12f3d-981e-a717-c8e5-bfbbfb7ec1a3@nvidia.com>
Date: Wed, 24 Jul 2019 16:23:21 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724061750.GA19397@infradead.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564010611; bh=U/byz8o3kezigETW8hWUjg+JqkNm/y0Q4UHjAnDVaRI=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=POKycPna3sFHaptSpPG8JFNhdv+KWPJt4Fqq7qra/U5uujHxVhga0mA2hyYe3oLWO
	 rvMjdBQgQaYdhe3tYVq3xzWzC7PXLH9gVg6v6GfrdnHKhzPSXOdrUzDa4Sfy+FpWme
	 AYx8XN4QHijtxUQThz9jDsFglp/BwmD6wmVyo2Ou4HoX36ySg8r0DnnWDfRMrkzmXC
	 XvSXsG7L9llJHump4bjV4yoH02Li7EYgdYhEFhGR3d1oO3a9DGx7nb70VEc+guaDrP
	 BAn4DIKE83X0lqImHCnmIIbgjVMdzz9Q4ePUhHR77cnRWD+JGehn4V8I2IYZgTvKbn
	 0ENu9Hbk0xmXw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/23/19 11:17 PM, Christoph Hellwig wrote:
> On Tue, Jul 23, 2019 at 09:25:06PM -0700, john.hubbard@gmail.com wrote:
>> * Store, in the iov_iter, a "came from gup (get_user_pages)" parameter.
>>   Then, use the new iov_iter_get_pages_use_gup() to retrieve it when
>>   it is time to release the pages. That allows choosing between put_page=
()
>>   and put_user_page*().
>>
>> * Pass in one more piece of information to bio_release_pages: a "from_gu=
p"
>>   parameter. Similar use as above.
>>
>> * Change the block layer, and several file systems, to use
>>   put_user_page*().
>=20
> I think we can do this in a simple and better way.  We have 5 ITER_*
> types.  Of those ITER_DISCARD as the name suggests never uses pages, so
> we can skip handling it.  ITER_PIPE is rejected =D1=96n the direct I/O pa=
th,
> which leaves us with three.
>=20
> Out of those ITER_BVEC needs a user page reference, so we want to call

               ^ ITER_IOVEC, I hope. Otherwise I'm hopeless lost. :)

> put_user_page* on it.  ITER_BVEC always already has page reference,
> which means in the block direct I/O path path we alread don't take
> a page reference.  We should extent that handling to all other calls
> of iov_iter_get_pages / iov_iter_get_pages_alloc.  I think we should
> just reject ITER_KVEC for direct I/O as well as we have no users and
> it is rather pointless.  Alternatively if we see a use for it the
> callers should always have a life page reference anyway (or might
> be on kmalloc memory), so we really should not take a reference either.
>=20
> In other words:  the only time we should ever have to put a page in
> this patch is when they are user pages.  We'll need to clean up
> various bits of code for that, but that can be done gradually before
> even getting to the actual put_user_pages conversion.
>=20

Sounds great. I'm part way into it and it doesn't look too bad. The main
question is where to scatter various checks and assertions, to keep
the kvecs out of direct I/0. Or at least keep the gups away from=20
direct I/0.


thanks,
--=20
John Hubbard
NVIDIA

