Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA6E9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:42:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D4FA20855
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:42:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="QuOqZVNN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D4FA20855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=samsung.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F020A8E0081; Thu, 21 Feb 2019 06:42:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB22E8E0075; Thu, 21 Feb 2019 06:42:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D05778E0081; Thu, 21 Feb 2019 06:42:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 806A28E0075
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:42:31 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id o7so21333411pfi.23
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:42:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:subject:to:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language:cms-type:references;
        bh=RoEnKte5TbYxHXQobQyjxIfEG7a0L7Q1iSVqGo69ASY=;
        b=K66RxB+VCkeipBc2SXdRAjS5j/gzmeuHwB1YKu0GC6x9197pu5VNxyWShk2biwWUH3
         6Yl26duuCOKqv637BdgwTStq0kN3K4/VlgVMMTd+qW4T2WQfY5cyZKB/sJgAwTWv81AX
         JwJLrtsOKX0YMZ5N18gFE4GdJhDh44iPo/TgDUHLTSBdXC4Rr1BgB+wWLMyjAJ7cUyTU
         NVqFNvIHosg7F0dRxxMSwegOMdQsQNI6vevHusng/wXJ74pbGECmDTgslv+0qAu9sVRn
         x4oRkcqKqaQNvUOlRjgGMLWrFFoe660ckkbTcCBXjMUaKI2AFTlV2v2Ob6hpw3lW4Veo
         Mh2A==
X-Gm-Message-State: AHQUAuYAHMIagNE3bsY0kM4g4KUgZaCuq1eIXpf6qAwk8vYdYsys9uWn
	VLZY8y9glkcfC6ViI3P/bVfrjSOk9OkaE6bmAWmxzCI3Jeb4PA0GK7Bi1wSXeRubVlCW8atpKOj
	u3PUo7QzsbaSkBHKg/yGyDkC5dEXGKGBCBwz7m0GC2bA5B7nmC9qiC5VUkrVwDwZA3A==
X-Received: by 2002:a17:902:5a8d:: with SMTP id r13mr42158324pli.190.1550749351115;
        Thu, 21 Feb 2019 03:42:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbhjtBUik/zzLcKwBV5Ln7K3QutJ3QOlPeFzqZddizQrvf4i8E8L1wObopS5/hKEzubdXfD
X-Received: by 2002:a17:902:5a8d:: with SMTP id r13mr42158267pli.190.1550749350186;
        Thu, 21 Feb 2019 03:42:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550749350; cv=none;
        d=google.com; s=arc-20160816;
        b=tXTbpaNde0fghapIfjLHSWhQQepVKerG4bqELWt284EeqDGkxoh7ynYWgfNIyzCEpH
         LHinv0N4s2TM38APpclIJvMOoOsXWE3ySdGu1+56HjbmibskgMax5HXOHcNxXrL/nmQR
         9bDJVQQ0RLvr4eKzU/Oz9woudosElahUWYmT41HzjvSNMOjctdSzbikLhKPL2a3i+Qwf
         evecayNbiaxgFXyaH4yHYP2oyONKiFfp6C/Gfuia73Hrdl28G4yZpGZlQqighZJQNKkp
         xIypFrZkJ3VP5C+TWOn5nzyacaV8cxK/m4yRkSsErDZ2ManT9Uusz3y7cffPn4Pj9+FE
         hiRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:cms-type:content-language:content-transfer-encoding
         :in-reply-to:mime-version:user-agent:date:message-id:from:cc:to
         :subject:dkim-signature:dkim-filter;
        bh=RoEnKte5TbYxHXQobQyjxIfEG7a0L7Q1iSVqGo69ASY=;
        b=Dt2tpSOoRkZBJH5eplgcQ6QA34OhtdqfRj6cNhr6mAqHAwff9eaxRBPL5PVvUA00uC
         Z7PeA8QNKvVUl2mHgqwQs5BiKBvL8mfP49KPHmRdFHp6LarVApx9syJOHKLWxXuPm+W/
         mQrgfVXfpXa8VdqBtnk2LVN6bcjtT0om5KW3g6ME9AYRZmcENdb8nb4lLu67rS6P414z
         mGbD29kNXrAVJJSXl91SEG6dAA+TCK3LjcTQJEiiLUZ61abUni8/QAwSV7MsXWzyMM6p
         TZy+nU4gM2Z1Tqn+f8lTqaMEY5+WDY/ijCq7xTO4zO4MaC9jVRbI6wMPiuVf8vdCuc0j
         axLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b=QuOqZVNN;
       spf=pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.11 as permitted sender) smtp.mailfrom=m.szyprowski@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id 21si2814232pgl.308.2019.02.21.03.42.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 03:42:30 -0800 (PST)
Received-SPF: pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.11 as permitted sender) client-ip=210.118.77.11;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b=QuOqZVNN;
       spf=pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.11 as permitted sender) smtp.mailfrom=m.szyprowski@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
	by mailout1.w1.samsung.com (KnoxPortal) with ESMTP id 20190221114226euoutp015c347dd654e46871fb05a5b70b11cfa0~FXlBxVh8R0617006170euoutp01K;
	Thu, 21 Feb 2019 11:42:26 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout1.w1.samsung.com 20190221114226euoutp015c347dd654e46871fb05a5b70b11cfa0~FXlBxVh8R0617006170euoutp01K
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1550749346;
	bh=RoEnKte5TbYxHXQobQyjxIfEG7a0L7Q1iSVqGo69ASY=;
	h=Subject:To:Cc:From:Date:In-Reply-To:References:From;
	b=QuOqZVNNKZGEOXbwE4+JghFksM1ldmAFTd6cuSkqXZ+T5F+RI1yQANBaLTCYPzJ9q
	 FnB5Cow1TuyLfwm4uyfC8fs/BJZQy7H0BEGj3JycMEdM4r96R+rr2n4iLqFD+LepEb
	 XHzP298CYg8Prj9CFypxivhQn1A3GI0hJ8AhakZc=
Received: from eusmges1new.samsung.com (unknown [203.254.199.242]) by
	eucas1p2.samsung.com (KnoxPortal) with ESMTP id
	20190221114225eucas1p29780f79a3421d9c246da2593d5858e2f~FXlBWNReU0974909749eucas1p2W;
	Thu, 21 Feb 2019 11:42:25 +0000 (GMT)
Received: from eucas1p1.samsung.com ( [182.198.249.206]) by
	eusmges1new.samsung.com (EUCPMTA) with SMTP id 56.28.04441.1AE8E6C5; Thu, 21
	Feb 2019 11:42:25 +0000 (GMT)
Received: from eusmtrp2.samsung.com (unknown [182.198.249.139]) by
	eucas1p2.samsung.com (KnoxPortal) with ESMTPA id
	20190221114224eucas1p24fb9b1d416ba709c4275cab3db276f0a~FXlAWWk862634926349eucas1p2E;
	Thu, 21 Feb 2019 11:42:24 +0000 (GMT)
Received: from eusmgms1.samsung.com (unknown [182.198.249.179]) by
	eusmtrp2.samsung.com (KnoxPortal) with ESMTP id
	20190221114224eusmtrp20c5a08142eb5d80dbe86dfadd96d8fc6~FXlAGTgF41150611506eusmtrp2v;
	Thu, 21 Feb 2019 11:42:24 +0000 (GMT)
X-AuditID: cbfec7f2-5e3ff70000001159-e6-5c6e8ea19df8
Received: from eusmtip1.samsung.com ( [203.254.199.221]) by
	eusmgms1.samsung.com (EUCPMTA) with SMTP id 1B.F4.04284.0AE8E6C5; Thu, 21
	Feb 2019 11:42:24 +0000 (GMT)
Received: from [106.116.147.30] (unknown [106.116.147.30]) by
	eusmtip1.samsung.com (KnoxPortal) with ESMTPA id
	20190221114223eusmtip129cbdd51698138069d8c0ab800ee596a~FXk_xKWxo2574125741eusmtip1u;
	Thu, 21 Feb 2019 11:42:23 +0000 (GMT)
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
Message-ID: <104e10f8-7aea-54ce-4fea-951768fa81c8@samsung.com>
Date: Thu, 21 Feb 2019 12:42:22 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
	Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190221103856.GC12448@ming.t460p>
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Brightmail-Tracker: H4sIAAAAAAAAA01Sf0xTVxjdfT/ue3TWPAuOG2EbNhEixh/EqXeRuc4sy52Jif/NIFE7fUEy
	Wm1rdTjNKhVkHdHJtoAFVLLNMQqtICB2rQYodAVplVo3iW3mYAtoaqdCNpYNRvtg47/znfOd
	fOckH08rHsJlfKH2sKjXqouUUMZ09E35V9ef0eav63dlYN9oE8S28FmIW6odLPbZRiCuOhng
	cDh2jcWDj+o47H5Sw+Lbf56k8MR0iMXf2Xop7Ck5hgOBKxzu67hHYffwKjw00sDh8xceQOxy
	+xgcdNZCHGmaYbFn5izApy86Aa4O3KCw8+9ODnd/bqbw2ONM3BMJMdhSUwqx/XGMwWUtkwCX
	Vkxx2Nv8Hg7842VVy4l9opol58xPOHLdGuZIINLCkFOeKEu+co1TJDhoJK2Nn0DS+qySIw/u
	uSD5/r4JkpJbvTR5+uswQ2I3QpCcaWsExNEWYnYk58ly94tFhUdE/dote2UHxu96mUPlmR82
	O4eACVgyLCCJR8JrqNx3i7IAGa8QGgAK95dAaZgAyG7/Zm54DlDUH6bnLWPtDkYSvgXoh5sR
	EBcUQgygrugrcZws5KJfLjcl+BRBicJhGxc30MI0j079MZUQoJCDLFELjGO5sAW1nRtl4pgR
	VqDwyAAbx0uFfPSF38NJO0uQ77y0kySsQ89rRxOJaOFVZG6vmcOpaHj0YqIQEq4mIfPYQyDF
	fhs1934KJZyMHnnbOAmno5nr8wYzQKerrZw0VADUXts559iMerx3ZiPxsydWIodzrUS/herd
	jgSNhMXop+gSKcRiVNlRRUu0HJWXKaTtTGT12v8723V7iP4MKK0LqlkX1LEuqGP9/+4lwDSC
	VNFo0BSIhhyteHSNQa0xGLUFa/Yd1LSC2ccfmPY+6wSTQ+93A4EHykXyKzs1+QpWfcRQrOkG
	iKeVKfJthdp8hXy/uviYqD+4R28sEg3dII1nlKnyj174eZdCKFAfFj8QxUOifl6l+KRlJtBJ
	YPG17LS6lGz/SLq/X5bep9jsfNH0Y2NlsCEynuX3bEq/8OXHqh161QDJaz+Rtdp19M0g2bp+
	l1v31/a03GZwvF/1Tl3sZh7hbT2OraHkHH3f7g3bK1YUOes37mmdfGnfb29QOt3XG9/VLVet
	0m0yZlX9vuj1YFnGttKnXYMvm5SM4YA6J5vWG9T/Al1y9Yb0AwAA
X-Brightmail-Tracker: H4sIAAAAAAAAA02SbUxTVxiAc3o/263JtUB6YGbKTcRsusoFGS8Ldv5ZcsMPY7LELXwEG7hp
	2WhrelsD/tgqTOcqQavJxMLExEgEyldFwA7Y1hVJJ1BXLcuIJVEgoSPAFE0kQRxQl/DvSd7n
	eU9O8rKEZoVKYyssdslmMVTytIq8vz4a++h6vaU4s6M+FUKzXhraYxdo6GnooiDUPkPDldNh
	BmLL/RSM//MTA0NLjRQ8eHVaAS/WoxS0to8oIFhzCsLhbgbu9U0qYGhqH0RmbjFw9dpjGgaH
	QiQ89DfRMO19Q0HwzQUE3zf7ETSEhxXgXxtgIHC5VgHzCxnw+3SUBFfjGRo6F5ZJONvzEsGZ
	ulUGRju+gPDrUepwutj5ooES3bVLjHjXE2PE8HQPKX4XXKTEG4Nxhfhw3CH62n6gRd/zS4z4
	eHKQFn/+20mLNWMjhPhsbooUl4ejtFjf24bErt4oeTSpUJdvszrs0m6TVbYf4osEyNIJeaDL
	OpinE7JzSz7JyuEP6PPLpcqKk5LtgP64zhR/NEqeOJdR1eGPICdy7XYhJYu5g3j+ThfpQipW
	w91EuHPsPJkY7MShH51UgpPw2qSLTkiLCHu9T9DmIInLx09bvFuczPE4FmtnNiWCcyrx08bf
	mEQxTuB/L8a3VtGcgF2Lm6uUrJrT41737NZzJLcHx2bubzgsm8IV4+gESig7cOhqQlFymXil
	aZbYZILbi9euRd7yLlx7p/Eta/HUbLPiItJ4tuWebYlnW+LZllxHZBtKlhyy2WiWBZ1sMMsO
	i1FXZjX70MbB9d1bvT2AIj2fBxDHIv5ddfeX5mINZTgpV5sDCLMEn6wuqLAUa9TlhupTks1a
	anNUSnIA5Wz8zU2kpZRZN87XYi8VcoRcyBNys3OzPwZeqw5nVhdqOKPBLn0tSSck2/+dglWm
	OdER0zvpYwWmBdYWPu7+6tz+YEX5o9dZJZ/te980kTGvarG0lMT7z+pLO84XDWt9Iyl3W43y
	Ia3229JPjxa6V6vqUm/sPTa+Gqzu1rfuD3zDp1d6nkQG6nwP+jl3alKZ6i918+34RDx/SfXe
	yh9/Nq3vnDMW9P3SPPdrTZV/6gNtq5InZZNB+JCwyYb/ADLNCNCGAwAA
X-CMS-MailID: 20190221114224eucas1p24fb9b1d416ba709c4275cab3db276f0a
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
	<9269fbbf-b5dd-6be1-682f-e791847ea00d@samsung.com>
	<20190221103856.GC12448@ming.t460p>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ming,

On 2019-02-21 11:38, Ming Lei wrote:
> On Thu, Feb 21, 2019 at 11:22:39AM +0100, Marek Szyprowski wrote:
>> On 2019-02-21 11:16, Ming Lei wrote:
>>> On Thu, Feb 21, 2019 at 11:08:19AM +0100, Marek Szyprowski wrote:
>>>> On 2019-02-21 10:57, Ming Lei wrote:
>>>>> On Thu, Feb 21, 2019 at 09:42:59AM +0100, Marek Szyprowski wrote:
>>>>>> On 2019-02-15 12:13, Ming Lei wrote:
>>>>>>> This patch pulls the trigger for multi-page bvecs.
>>>>>>>
>>>>>>> Reviewed-by: Omar Sandoval <osandov@fb.com>
>>>>>>> Signed-off-by: Ming Lei <ming.lei@redhat.com>
>>>>>> Since Linux next-20190218 I've observed problems with block layer on one
>>>>>> of my test devices (Odroid U3 with EXT4 rootfs on SD card). Bisecting
>>>>>> this issue led me to this change. This is also the first linux-next
>>>>>> release with this change merged. The issue is fully reproducible and can
>>>>>> be observed in the following kernel log:
>>>>>>
>>>>>> sdhci: Secure Digital Host Controller Interface driver
>>>>>> sdhci: Copyright(c) Pierre Ossman
>>>>>> s3c-sdhci 12530000.sdhci: clock source 2: mmc_busclk.2 (100000000 Hz)
>>>>>> s3c-sdhci 12530000.sdhci: Got CD GPIO
>>>>>> mmc0: SDHCI controller on samsung-hsmmc [12530000.sdhci] using ADMA
>>>>>> mmc0: new high speed SDHC card at address aaaa
>>>>>> mmcblk0: mmc0:aaaa SL16G 14.8 GiB
>>>>>>
>>>>>> ...
>>>>>>
>>>>>> EXT4-fs (mmcblk0p2): INFO: recovery required on readonly filesystem
>>>>>> EXT4-fs (mmcblk0p2): write access will be enabled during recovery
>>>>>> EXT4-fs (mmcblk0p2): recovery complete
>>>>>> EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
>>>>>> VFS: Mounted root (ext4 filesystem) readonly on device 179:2.
>>>>>> devtmpfs: mounted
>>>>>> Freeing unused kernel memory: 1024K
>>>>>> hub 1-3:1.0: USB hub found
>>>>>> Run /sbin/init as init process
>>>>>> hub 1-3:1.0: 3 ports detected
>>>>>> *** stack smashing detected ***: <unknown> terminated
>>>>>> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000004
>>>>>> CPU: 1 PID: 1 Comm: init Not tainted 5.0.0-rc6-next-20190218 #1546
>>>>>> Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
>>>>>> [<c01118d0>] (unwind_backtrace) from [<c010d794>] (show_stack+0x10/0x14)
>>>>>> [<c010d794>] (show_stack) from [<c09ff8a4>] (dump_stack+0x90/0xc8)
>>>>>> [<c09ff8a4>] (dump_stack) from [<c0125944>] (panic+0xfc/0x304)
>>>>>> [<c0125944>] (panic) from [<c012bc98>] (do_exit+0xabc/0xc6c)
>>>>>> [<c012bc98>] (do_exit) from [<c012c100>] (do_group_exit+0x3c/0xbc)
>>>>>> [<c012c100>] (do_group_exit) from [<c0138908>] (get_signal+0x130/0xbf4)
>>>>>> [<c0138908>] (get_signal) from [<c010c7a0>] (do_work_pending+0x130/0x618)
>>>>>> [<c010c7a0>] (do_work_pending) from [<c0101034>]
>>>>>> (slow_work_pending+0xc/0x20)
>>>>>> Exception stack(0xe88c3fb0 to 0xe88c3ff8)
>>>>>> 3fa0:                                     00000000 bea7787c 00000005
>>>>>> b6e8d0b8
>>>>>> 3fc0: bea77a18 b6f92010 b6e8d0b8 00000001 b6e8d0c8 00000001 b6e8c000
>>>>>> bea77b60
>>>>>> 3fe0: 00000020 bea77998 ffffffff b6d52368 60000050 ffffffff
>>>>>> CPU3: stopping
>>>>>>
>>>>>> I would like to help debugging and fixing this issue, but I don't really
>>>>>> have idea where to start. Here are some more detailed information about
>>>>>> my test system:
>>>>>>
>>>>>> 1. Board: ARM 32bit Samsung Exynos4412-based Odroid U3 (device tree
>>>>>> source: arch/arm/boot/dts/exynos4412-odroidu3.dts)
>>>>>>
>>>>>> 2. Block device: MMC/SDHCI/SDHCI-S3C with SD card
>>>>>> (drivers/mmc/host/sdhci-s3c.c driver, sdhci_2 device node in the device
>>>>>> tree)
>>>>>>
>>>>>> 3. Rootfs: Ext4
>>>>>>
>>>>>> 4. Kernel config: arch/arm/configs/exynos_defconfig
>>>>>>
>>>>>> I can gather more logs if needed, just let me which kernel option to
>>>>>> enable. Reverting this commit on top of next-20190218 as well as current
>>>>>> linux-next (tested with next-20190221) fixes this issue and makes the
>>>>>> system bootable again.
>>>>> Could you test the patch in following link and see if it can make a difference?
>>>>>
>>>>> https://marc.info/?l=linux-aio&m=155070355614541&w=2
>>>> I've tested that patch, but it doesn't make any difference on the test
>>>> system. In the log I see no warning added by it.
>>> I guess it might be related with memory corruption, could you enable the
>>> following debug options and post the dmesg log?
>>>
>>> CONFIG_DEBUG_STACKOVERFLOW=y
>>> CONFIG_KASAN=y
>> It won't be that easy as none of the above options is available on ARM
>> 32bit. I will try to apply some ARM KASAN patches floating on the net
>> and let you know the result.
> Hi Marek,
>
> Could you test the following patch?

Yes. Sadly, no change observed.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

