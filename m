Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C80EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 10:22:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D16220855
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 10:22:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="Bh6qVi3C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D16220855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=samsung.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE15A8E006F; Thu, 21 Feb 2019 05:22:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D67EB8E0002; Thu, 21 Feb 2019 05:22:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE2718E006F; Thu, 21 Feb 2019 05:22:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75DA08E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 05:22:48 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 23so9210230pgr.11
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 02:22:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:subject:to:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language:cms-type:references;
        bh=EFlVmu98y+0PhGS7qgg0E11evJwCh0HB1UidZWgItzM=;
        b=oHbfok8cdTNe5VBY3kr64XTWUonQXtCI9hrCOVY/bJn5jRdsmG7LUM6pdoLM5EAqgy
         H3TvTpVaKGRnLo2L04/mwXbfDpeQpItnyd8Ux2ZRk76NjPKJZQ/yRhNvsRiddk6MhVjP
         fPfJ42uNcetOLM/zJv1z1zJC6FX+8/TDf2pEkJ+wD1sRaBEYuvJ8d5CBRk/gG7l8VOPi
         U1EyQV+/4u+fZ1L4foSOeTbNEq7lXpCTR4N1RHkk9vNgp+H5JXrp6Yv5EI3G2ZPqLGOm
         dmmBY8t4ukVPoiFFLs2mrEK+M2JEBYT5W1BFPb8R4vZ1D8uShfyV54nO2/EME4nuxAjE
         g8WA==
X-Gm-Message-State: AHQUAuYeVfzb4IQatwIELT77IYeQydOKn9ccOqmTrIZDvtVp4LN8CqTi
	sM8Rh5r5f8MwHPm/7hnJTQg4l/itLqwy4gKv1Qyh0ppjGjJOvXiKDEak2wo4HXitqHSac0VgmNL
	Um4Y2CmmeDiMQcq687n4ay4MXXk1cO7pnJuagTwq18OfWLwPJ370Ymh7W0SklkriYkQ==
X-Received: by 2002:a63:e03:: with SMTP id d3mr6754855pgl.245.1550744568098;
        Thu, 21 Feb 2019 02:22:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibdf9PShu4a9aXm2eL99Er3UVlyqEV9kSeWIewZDzBP6rfQGLNECw44fwfu7RX3dWy804Bx
X-Received: by 2002:a63:e03:: with SMTP id d3mr6754794pgl.245.1550744567228;
        Thu, 21 Feb 2019 02:22:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550744567; cv=none;
        d=google.com; s=arc-20160816;
        b=PsGauF6FTJr/QOvwSWr/yQjxpAhevCFNigqceV/0Sb2PzJ7BsMY1UxmfTFYjmsPpPT
         jiF2fWizlacWcku9Ho7+9Jk28iHZw+lXHjLm9h1VWUfUHn1r5jue6NjG6kxSPgLq6W7f
         F+pnblbK1AAYSyRSkK+TsU0hHOQmaVgew2jo5gScKD0GjMLhlXQ8hfZluhxRuu1j//OZ
         yP5doW2vKkH+w/D9cNmkul34cKgPZ85xp/r7OoCJIZUlv7nXRrNvHVTlZAunV5Wo6eOT
         CJ88zr3pknxkOCzfMJPq3Bt7HweNz1XRNWiUIzwAutIl3hnKDVXxGJnXEFAH3IJcdZEC
         5laQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:cms-type:content-language:content-transfer-encoding
         :in-reply-to:mime-version:user-agent:date:message-id:from:cc:to
         :subject:dkim-signature:dkim-filter;
        bh=EFlVmu98y+0PhGS7qgg0E11evJwCh0HB1UidZWgItzM=;
        b=vk7UAimLtI00YAIkwzdW2YQTyVp+hPR3nQ/65qUfkIM2ePuWWFAEQisnqJFPUpAZ36
         ny81z3o7y29HzCe4neK/rJ7haI2MTdM6+zv2FrXRDU2IIzoGh4L7UGd8zAKNDt+9N9Ng
         TWvZi7DP/39fLqkBoDg47wY1wp3hFXZjCIxCERPaFRgF4qhJtLemuQS3Pv7XziIZ9q5u
         s1ppIRFh1pFtPi5lQLXWMXzLxeaCjDbpk0KW5leYHu+kk9Zdqyk/DZzFZ7wFF8MP81o0
         7NiYljjzIEXfILrqnSG+ekwdvc8GUvFjC3OpuRi16C0iGCgsSsgFGkJSeiTsM9AZtBQF
         OaQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b=Bh6qVi3C;
       spf=pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.12 as permitted sender) smtp.mailfrom=m.szyprowski@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id u64si21145476pfi.239.2019.02.21.02.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 02:22:47 -0800 (PST)
Received-SPF: pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.12 as permitted sender) client-ip=210.118.77.12;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b=Bh6qVi3C;
       spf=pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.12 as permitted sender) smtp.mailfrom=m.szyprowski@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
	by mailout2.w1.samsung.com (KnoxPortal) with ESMTP id 20190221102243euoutp02dcfb24baff2dada50016726e9fc0c84a~FWfbZZKSV2345623456euoutp02p;
	Thu, 21 Feb 2019 10:22:43 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout2.w1.samsung.com 20190221102243euoutp02dcfb24baff2dada50016726e9fc0c84a~FWfbZZKSV2345623456euoutp02p
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1550744563;
	bh=EFlVmu98y+0PhGS7qgg0E11evJwCh0HB1UidZWgItzM=;
	h=Subject:To:Cc:From:Date:In-Reply-To:References:From;
	b=Bh6qVi3ChXvLhL0KQnsy/GU4tK051NURBUWPr/qPZ6srhKTiwDs4Gid0LKhZSo8dK
	 YW3gizEb6WvKA4jgcuOnACgLzox9/T9I7A1/CF+3MOrH0UB5vEYvMqBCWqj9fApsCK
	 Pmy4VM1D3y24opN8CY9XbeBgwb1kYOveWhW/jUlw=
Received: from eusmges1new.samsung.com (unknown [203.254.199.242]) by
	eucas1p2.samsung.com (KnoxPortal) with ESMTP id
	20190221102242eucas1p2756ea9d3a5a1adf5c40bddb18578de48~FWfa7l6q52341823418eucas1p2y;
	Thu, 21 Feb 2019 10:22:42 +0000 (GMT)
Received: from eucas1p2.samsung.com ( [182.198.249.207]) by
	eusmges1new.samsung.com (EUCPMTA) with SMTP id A4.7B.04441.2FB7E6C5; Thu, 21
	Feb 2019 10:22:42 +0000 (GMT)
Received: from eusmtrp1.samsung.com (unknown [182.198.249.138]) by
	eucas1p2.samsung.com (KnoxPortal) with ESMTPA id
	20190221102241eucas1p2ce2ef05e3262a0ac61e4f65a7d8f9148~FWfZ9UABW2330523305eucas1p2R;
	Thu, 21 Feb 2019 10:22:41 +0000 (GMT)
Received: from eusmgms2.samsung.com (unknown [182.198.249.180]) by
	eusmtrp1.samsung.com (KnoxPortal) with ESMTP id
	20190221102241eusmtrp1478bf4391dd5bb733aa2a4b68f539985~FWfZsRwQ21408214082eusmtrp1M;
	Thu, 21 Feb 2019 10:22:41 +0000 (GMT)
X-AuditID: cbfec7f2-a1ae89c000001159-94-5c6e7bf27ca8
Received: from eusmtip2.samsung.com ( [203.254.199.222]) by
	eusmgms2.samsung.com (EUCPMTA) with SMTP id 1E.80.04128.1FB7E6C5; Thu, 21
	Feb 2019 10:22:41 +0000 (GMT)
Received: from [106.116.147.30] (unknown [106.116.147.30]) by
	eusmtip2.samsung.com (KnoxPortal) with ESMTPA id
	20190221102240eusmtip2b5179453b2ae60f69fb714e125879d7a~FWfYUSj8S0043700437eusmtip2q;
	Thu, 21 Feb 2019 10:22:40 +0000 (GMT)
Subject: Re: [PATCH V15 14/18] block: enable multipage bvecs
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o
	<tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg
	<sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet
	<kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>,
	dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, David Sterba
	<dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong"
	<darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang
	<gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>,
	linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob
	Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ulf Hansson
	<ulf.hansson@linaro.org>, "linux-mmc@vger.kernel.org"
	<linux-mmc@vger.kernel.org>, 'Linux Samsung SOC'
	<linux-samsung-soc@vger.kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>,
	Adrian Hunter <adrian.hunter@intel.com>, Bartlomiej Zolnierkiewicz
	<b.zolnierkie@samsung.com>
From: Marek Szyprowski <m.szyprowski@samsung.com>
Message-ID: <9269fbbf-b5dd-6be1-682f-e791847ea00d@samsung.com>
Date: Thu, 21 Feb 2019 11:22:39 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
	Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190221101618.GB12448@ming.t460p>
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Brightmail-Tracker: H4sIAAAAAAAAA01Sf0zUdRj28/19N899PCze1Gady1kskMUfny3HyFn71GrpsumSqZd+A4o7
	2B0YaGsgoHWxMGjj/OKPAlYKyAHHERJH8zi8bmpn4LFiHNMOt4TgxnmWuDrz+GLx3/M87/O+
	z/tur8TqbwqrpTxzkWwxG/MNgpbruTQfeD562Jy9qSmwkfgn2wTSGqoRSKfdwRN/a1gg9eUB
	kYQi3/Hk6tQpkbhnG3hy7V45Q2LxIE/OtQ4xxHvkEAkEOkRyqWeUIe6xFDIcPiuSE6fHBdLv
	9nNkpO+kQCbaHvDE+6AGkWNn+hCxBwYY0vd3r0g8dRUM+X16AxmcCHLE1lAlkPbpCEeOdt5F
	pKp6XiS+8ztJ4B8fn/U0bY/ZefpFxaxILyghkQYmOjla6Z3haVP/bYaOXC2mXS2fCrQrWivS
	8dF+gX7/a5lAj1wZYuncrTGORgaCAv28uwVRR3eQ25b0jnbzATk/76BsScvcp81tnvKjwrr1
	JaPB60wZ+uFJG9JIgDPgygU3b0NaSY/PInDGaxdJDMFcm19QyR0E/nPz6FFLY6OLUwvfIrhx
	q0NUSQTBSI2DS7iS8Gb47Zu2hY5V2AChUOuCicVxCSr/UkcJOB1sMzYhgXU4E8ri0YdYkjj8
	DMTKtQn5MZwNX/7kFVXLSvCfmFyYr8GbYLjqDzaBWbwOKlwNizgZxibPMIkswA4NVDqHRHXt
	rXDzuJNRcRJM+boX9bVwua6aUxsqEByzK6JKqhG4TvYKqutFGPT9zCe2Y/Gz4OhLU+WX4Gu3
	Y0EGvAJ+mVmpLrECanvqWVXWwSdH9ap7Ayi+9v9iL14bZo8jg7LkNGXJOcqSc5T/c79CXAtK
	loutphzZmm6WP0y1Gk3WYnNO6v4CUxd6+PiX475oL7o7/K4HYQkZlus6dpmy9bzxoLXU5EEg
	sYZVutfyzNl63QFj6SHZUrDXUpwvWz1ojcQZknWHl93Yrcc5xiL5A1kulC2PqoykWV2GtueX
	ZNwvUKCdbMTzWWtKmmarQ86CsS23X62PZsQys7Dxx4+mG+h7W96YDhelNu7Y7vC/UJeyX3P/
	Kdf4uvqUz8DzRBjbBzpPRy4Whm2Kd8/cneCytPd3vH3e/ZaTSyqdaIaX/7w31fv49WbTmynb
	aOkrH+9y9cyuDQzmLh95vXKrgbPmGtOfYy1W479GnEMx9AMAAA==
X-Brightmail-Tracker: H4sIAAAAAAAAA02Sa0xTZxjH8557id0OBcIrmRfOpm5eKm1hfTCM+PHNsiUmLpkXmDZ4BsRe
	tKd14r4UGJI1G85pJrYITjczARUIXoaArhZJFa0iJUpsTbAmeClog4lmgKPWJXz7Jf/f78OT
	PAKtibNZQrnVIdutJrPEpTDXZ/ojq158by3Kaa1eCIFoKwct4X0ctNefYSHQ8pCDQ5VBHsIT
	51m48eQIDz3jXhZuvaqkYHImxMLJlj4K/FV7IBhs4+HquWEKekZWwODDv3g43Hifg+6eAAN3
	uho4iLS+YcH/Zh+C2qYuBPXBXgq6pi7w4DtQTcHY06VwJRJiwO2t4eD00wkG9ra/RFDz02se
	+k99DcHpfnZtNjk9Wc+S/dXjPPnbE+ZJMNLOkB/8MZYc735MkTs3nKSj+UeOdMR/5cn94W6O
	XLzn4kjVQB9NXjwaYchEb4gjdZ3NiJzpDDHr0jZpC+w2p0NeXGZTHJ9Jm3Wg1+ryQavPzdfq
	DMbiNfo8aXVhwTbZXL5Ltq8u3Kot++NJAO048OHu4dAQ5UKXFriRSsBiLj527CzjRimCRvwT
	4RM3B1By+AAHfnOxSU7DU8NuLinFEK6t6+USQ5pYgEdPtL4N0kUJh8MtfEKiRZcKj3r/4ZNF
	nMLBoSiVsDhRh90x99taLRZi10x8lgWBEZfgycqUBGaIRTh0EyWNVBw4HGUSrBJz8GDNMzrB
	tLgMTzUOvuNFuPqs9x1n4pFoE/UL0njm5J45iWdO4pmTHEVMM0qXnYql1KLotYrJojitpdoS
	m6UDzf7buauvOy8g9/h6HxIFJM1Tt22wFGlY0y6lwuJDWKCldPXn5dYijXqbqWKPbLdtsTvN
	suJDebOn7aezMkpss99rdWzR5emMkK8zGoyGT0HKVAdzKjZpxFKTQ94uyztk+/8dJaiyXKhg
	0NuwiG6MNuyNDXyXurFNeuAeXanPHoosCW/8V1xzN3fxyS+3j5Hb5pGx9zMNX136eGfp700l
	8+/21E6GAt8+V4rRM/8XxRedqr6fn2dQn2Dj0vhu5bhkWFD7XlWG+Zu1G9S8x795oeqjddbL
	B2OGad+hNN90bnZv3u3Ug9ca6wISo5SZdMtpu2L6DwIYf2qFAwAA
X-CMS-MailID: 20190221102241eucas1p2ce2ef05e3262a0ac61e4f65a7d8f9148
X-Msg-Generator: CA
Content-Type: text/plain; charset="utf-8"
X-RootMTR: 20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d
X-EPHeader: CA
CMS-TYPE: 201P
X-CMS-RootMailID: 20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d
References: <20190215111324.30129-1-ming.lei@redhat.com>
	<20190215111324.30129-15-ming.lei@redhat.com>
	<CGME20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d@eucas1p1.samsung.com>
	<6c9ae4de-c56f-a2b3-2542-da7d8b95601d@samsung.com>
	<20190221095733.GA12448@ming.t460p>
	<ba39138d-d65b-335d-d709-b95dbde1fd5c@samsung.com>
	<20190221101618.GB12448@ming.t460p>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ming,

On 2019-02-21 11:16, Ming Lei wrote:
> On Thu, Feb 21, 2019 at 11:08:19AM +0100, Marek Szyprowski wrote:
>> On 2019-02-21 10:57, Ming Lei wrote:
>>> On Thu, Feb 21, 2019 at 09:42:59AM +0100, Marek Szyprowski wrote:
>>>> On 2019-02-15 12:13, Ming Lei wrote:
>>>>> This patch pulls the trigger for multi-page bvecs.
>>>>>
>>>>> Reviewed-by: Omar Sandoval <osandov@fb.com>
>>>>> Signed-off-by: Ming Lei <ming.lei@redhat.com>
>>>> Since Linux next-20190218 I've observed problems with block layer on one
>>>> of my test devices (Odroid U3 with EXT4 rootfs on SD card). Bisecting
>>>> this issue led me to this change. This is also the first linux-next
>>>> release with this change merged. The issue is fully reproducible and can
>>>> be observed in the following kernel log:
>>>>
>>>> sdhci: Secure Digital Host Controller Interface driver
>>>> sdhci: Copyright(c) Pierre Ossman
>>>> s3c-sdhci 12530000.sdhci: clock source 2: mmc_busclk.2 (100000000 Hz)
>>>> s3c-sdhci 12530000.sdhci: Got CD GPIO
>>>> mmc0: SDHCI controller on samsung-hsmmc [12530000.sdhci] using ADMA
>>>> mmc0: new high speed SDHC card at address aaaa
>>>> mmcblk0: mmc0:aaaa SL16G 14.8 GiB
>>>>
>>>> ...
>>>>
>>>> EXT4-fs (mmcblk0p2): INFO: recovery required on readonly filesystem
>>>> EXT4-fs (mmcblk0p2): write access will be enabled during recovery
>>>> EXT4-fs (mmcblk0p2): recovery complete
>>>> EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
>>>> VFS: Mounted root (ext4 filesystem) readonly on device 179:2.
>>>> devtmpfs: mounted
>>>> Freeing unused kernel memory: 1024K
>>>> hub 1-3:1.0: USB hub found
>>>> Run /sbin/init as init process
>>>> hub 1-3:1.0: 3 ports detected
>>>> *** stack smashing detected ***: <unknown> terminated
>>>> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000004
>>>> CPU: 1 PID: 1 Comm: init Not tainted 5.0.0-rc6-next-20190218 #1546
>>>> Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
>>>> [<c01118d0>] (unwind_backtrace) from [<c010d794>] (show_stack+0x10/0x14)
>>>> [<c010d794>] (show_stack) from [<c09ff8a4>] (dump_stack+0x90/0xc8)
>>>> [<c09ff8a4>] (dump_stack) from [<c0125944>] (panic+0xfc/0x304)
>>>> [<c0125944>] (panic) from [<c012bc98>] (do_exit+0xabc/0xc6c)
>>>> [<c012bc98>] (do_exit) from [<c012c100>] (do_group_exit+0x3c/0xbc)
>>>> [<c012c100>] (do_group_exit) from [<c0138908>] (get_signal+0x130/0xbf4)
>>>> [<c0138908>] (get_signal) from [<c010c7a0>] (do_work_pending+0x130/0x618)
>>>> [<c010c7a0>] (do_work_pending) from [<c0101034>]
>>>> (slow_work_pending+0xc/0x20)
>>>> Exception stack(0xe88c3fb0 to 0xe88c3ff8)
>>>> 3fa0:                                     00000000 bea7787c 00000005
>>>> b6e8d0b8
>>>> 3fc0: bea77a18 b6f92010 b6e8d0b8 00000001 b6e8d0c8 00000001 b6e8c000
>>>> bea77b60
>>>> 3fe0: 00000020 bea77998 ffffffff b6d52368 60000050 ffffffff
>>>> CPU3: stopping
>>>>
>>>> I would like to help debugging and fixing this issue, but I don't really
>>>> have idea where to start. Here are some more detailed information about
>>>> my test system:
>>>>
>>>> 1. Board: ARM 32bit Samsung Exynos4412-based Odroid U3 (device tree
>>>> source: arch/arm/boot/dts/exynos4412-odroidu3.dts)
>>>>
>>>> 2. Block device: MMC/SDHCI/SDHCI-S3C with SD card
>>>> (drivers/mmc/host/sdhci-s3c.c driver, sdhci_2 device node in the device
>>>> tree)
>>>>
>>>> 3. Rootfs: Ext4
>>>>
>>>> 4. Kernel config: arch/arm/configs/exynos_defconfig
>>>>
>>>> I can gather more logs if needed, just let me which kernel option to
>>>> enable. Reverting this commit on top of next-20190218 as well as current
>>>> linux-next (tested with next-20190221) fixes this issue and makes the
>>>> system bootable again.
>>> Could you test the patch in following link and see if it can make a difference?
>>>
>>> https://marc.info/?l=linux-aio&m=155070355614541&w=2
>> I've tested that patch, but it doesn't make any difference on the test
>> system. In the log I see no warning added by it.
> I guess it might be related with memory corruption, could you enable the
> following debug options and post the dmesg log?
>
> CONFIG_DEBUG_STACKOVERFLOW=y
> CONFIG_KASAN=y

It won't be that easy as none of the above options is available on ARM
32bit. I will try to apply some ARM KASAN patches floating on the net
and let you know the result.

Best regards

-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

