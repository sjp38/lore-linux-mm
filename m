Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E91DC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 10:08:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2CA12147A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 10:08:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="viZscJb8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2CA12147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=samsung.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BD968E006D; Thu, 21 Feb 2019 05:08:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66DA58E0002; Thu, 21 Feb 2019 05:08:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50EB28E006D; Thu, 21 Feb 2019 05:08:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7598E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 05:08:29 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so19127104pgq.9
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 02:08:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:subject:to:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language:cms-type:references;
        bh=MVi2CGXU4cvPoR7+81AtFxRL5Jytnmo8E2nT4MfJIOU=;
        b=NPACMgw11rLqSKhfpqA7NdyV5Ze63FIktKG9kYWduaoAg0yUmmVut9GfXmsMhdF7Vy
         9tiSM05GR0hMAeNtYOliHLz1luXs1DfKpK8tX28M8MGzuZoe0H13bTIJWpshOrzw94jQ
         sRdWPoP6Nmj1T3FIFiJogMGxSrbBQeC/O7SvLe5tmsjVqfXJji3A59ft6rgwG6bLVB4r
         wv8WCKujHa+NjVg9FnAAHW1GdwKU+lk1egCxr491C5i1/vZAYJwTVwauU0RURLCxUs1Q
         oebD67pxhZjbHd5NvzXWFh83aiArx2Wm0hQ9QhJnh4SD9h5o3raliM5jQZNV23WUv6e6
         vVZg==
X-Gm-Message-State: AHQUAub16xK7Zvb4Puoc8m45exngX51UPeqLV9j4yGgJa4sVOgJGS4OU
	FOYt0Og8BdNBHQ18XgnYGNA13sBxIYz3i9uJxQiWD/FbMqz6MXrU8SyG+Yk0IKX22T6hBOP8ja/
	kwOjejdzDOSlzVYCcWaE8Z1IdQ4P5Y+8oKlaDIvjDLKVThKhSdEWP5lTk9SnldF5paw==
X-Received: by 2002:a17:902:b097:: with SMTP id p23mr40263724plr.36.1550743708608;
        Thu, 21 Feb 2019 02:08:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iab3ZKY12wVXNBjcaq5tfctjvouFOa/XnHeCMuNtG3ZPaeLaU1nwzehmGglrbLwLOVd0Gdw
X-Received: by 2002:a17:902:b097:: with SMTP id p23mr40263634plr.36.1550743707598;
        Thu, 21 Feb 2019 02:08:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550743707; cv=none;
        d=google.com; s=arc-20160816;
        b=vuZPv49SQesz2qF0ilN80DS5Bb3teKDyfxbbdXT1hZNyKINA6fTthC8N/j1jnPB3Ze
         JHZRQHJdNKf9oDcEpD33/mEsE9D6wo4OhXTkyjF3R9HMQzEod2/sn1g6mHl4Vq2ah4ai
         U1giyeqblcBT0Q2wC41rd5wqpVPttartCHj22YSPptx6vpsNyJ0kok/XOoVHChYNdoEh
         u++0gtOaDTHZIBrJ9fEoIuM895bfytMgJWmRP10J+EDrfSDHK0jbONZv8x/8AYTt0rCO
         dEUFoPZkPT4UP6D24p8CZj7kGR9MVOitoNJE5kICEhTbVSXqH7K7DsvNNCnnUrxOWgop
         S5qA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:cms-type:content-language:content-transfer-encoding
         :in-reply-to:mime-version:user-agent:date:message-id:from:cc:to
         :subject:dkim-signature:dkim-filter;
        bh=MVi2CGXU4cvPoR7+81AtFxRL5Jytnmo8E2nT4MfJIOU=;
        b=tfslRHtivY5rgB+Kx37sTsEqDpJXy5K4lQEzsq9q8avH6J3xAxyoMDAzruJ88LpKa6
         JRpX2VsUL8AbSShIJyaxCXfno0ApxEmV8xyyjeBX40NevgcxdD7Ga4yvSND2TS9JbT4S
         xBvG4ovHDxFhDZRvdv7GabDUCgKEKzBVnHAPYM4r2ggw8rPvwC/0MU4FGIpHt9STO7Vu
         Jm3hE4f/5qryUgovW/6K8kkdUqTdYCCIqCrXbQEK4CoqlwRLvv9N8ZdMHiRmbRfru6KJ
         3TqF4AP+WE3qmjRz9/qtfM6j5CEKOj8LatK9tz5/VrQ8RdAek2YRyrNOKpms/vNjaLr+
         0GDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b=viZscJb8;
       spf=pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.11 as permitted sender) smtp.mailfrom=m.szyprowski@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id bc12si10682970plb.13.2019.02.21.02.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 02:08:27 -0800 (PST)
Received-SPF: pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.11 as permitted sender) client-ip=210.118.77.11;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b=viZscJb8;
       spf=pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.11 as permitted sender) smtp.mailfrom=m.szyprowski@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from eucas1p2.samsung.com (unknown [182.198.249.207])
	by mailout1.w1.samsung.com (KnoxPortal) with ESMTP id 20190221100823euoutp01c8800466c60ffd43c88376eaded2afc2~FWS6yCvLR1720417204euoutp01Y;
	Thu, 21 Feb 2019 10:08:23 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout1.w1.samsung.com 20190221100823euoutp01c8800466c60ffd43c88376eaded2afc2~FWS6yCvLR1720417204euoutp01Y
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1550743703;
	bh=MVi2CGXU4cvPoR7+81AtFxRL5Jytnmo8E2nT4MfJIOU=;
	h=Subject:To:Cc:From:Date:In-Reply-To:References:From;
	b=viZscJb8uegqmNprg1h2N4D8aqSdn20l2Ly1taI2orz9pI1XZHRtIHt39Z/fGHzLS
	 B7NdySR2fu9QAYsSqgT94qmhoLuHerIlquMxjwk6hNEQBSMrKc2FaoYINd2+KdXJKs
	 mE4NaMmX86GNcN8rnbnh7MZ1NEc95UkV+VNvCLBg=
Received: from eusmges3new.samsung.com (unknown [203.254.199.245]) by
	eucas1p1.samsung.com (KnoxPortal) with ESMTP id
	20190221100823eucas1p110853bdfa043ad5a3cf3a539f2667a62~FWS6HC3rF0811408114eucas1p1g;
	Thu, 21 Feb 2019 10:08:23 +0000 (GMT)
Received: from eucas1p1.samsung.com ( [182.198.249.206]) by
	eusmges3new.samsung.com (EUCPMTA) with SMTP id 09.C5.04806.6987E6C5; Thu, 21
	Feb 2019 10:08:22 +0000 (GMT)
Received: from eusmtrp1.samsung.com (unknown [182.198.249.138]) by
	eucas1p2.samsung.com (KnoxPortal) with ESMTPA id
	20190221100821eucas1p2ec6440cf2b734261cbddb47321b37fd7~FWS5C6gmE2936529365eucas1p2b;
	Thu, 21 Feb 2019 10:08:21 +0000 (GMT)
Received: from eusmgms2.samsung.com (unknown [182.198.249.180]) by
	eusmtrp1.samsung.com (KnoxPortal) with ESMTP id
	20190221100821eusmtrp15492a1e2268ee2cbb4e06f771dbe1f3a~FWS4ycOTB0967009670eusmtrp1h;
	Thu, 21 Feb 2019 10:08:21 +0000 (GMT)
X-AuditID: cbfec7f5-34dff700000012c6-c1-5c6e78968a6f
Received: from eusmtip1.samsung.com ( [203.254.199.221]) by
	eusmgms2.samsung.com (EUCPMTA) with SMTP id 53.4E.04128.5987E6C5; Thu, 21
	Feb 2019 10:08:21 +0000 (GMT)
Received: from [106.116.147.30] (unknown [106.116.147.30]) by
	eusmtip1.samsung.com (KnoxPortal) with ESMTPA id
	20190221100820eusmtip173e0051c5cb37c326434925225590ecb~FWS3fu0qy3193531935eusmtip1q;
	Thu, 21 Feb 2019 10:08:20 +0000 (GMT)
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
Message-ID: <ba39138d-d65b-335d-d709-b95dbde1fd5c@samsung.com>
Date: Thu, 21 Feb 2019 11:08:19 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
	Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190221095733.GA12448@ming.t460p>
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Brightmail-Tracker: H4sIAAAAAAAAA01SbUyTVxj1vt80q7kWJ8/82GKzYbYFULdkd1un0y3bm5m4mZDoNjJW9R0Q
	20JaquISA9SPWYmKuAlFh2RRkDIKla/ylQiVpkOpChitlCxYtwmjZBsGmVpm+1bHv/Oc55x7
	npNcgVaNcouFLEOuZDRodWpOwTT3zvQn/bDbkLayqiKJeIO1HLEHjnKkodTBEq/9DkdOFvh4
	EphsYcmVsdM86QyVs+TqgwKKTIWHWHLefoki7sI9xOer50lv8w2KdPpfJ9fvVPOk7MdhjnR0
	ehky0HaKIyO1syxxzx5F5GBFGyKlvi6KtD1q5Ul3iYUif4wnkp6RIYZYy/dzpG58kiEHGu4j
	sr9ohieenzcT32MP+/5ysW6qlBWLLSFedNkCvOgbaWDEfe4JVvyp4x4lDlwxi86aQ5zo/Ps4
	Lw7f6ODE9lv5nFh4+RIt/nXXz4iTXUOceKSxBomOxiHms/gvFJrtki5rp2RMWfO1IvPY6UKU
	c+7F3RcmHrL5yPmCFcUJgN+ElqIezooUggpXI/iz5B6ShykE7ZYxWh7+QdBa5eefWpy3f4up
	qhD0Vthj/kkEtz1VTEQVjzUweq4WRfBCrIZAwM5HRDQOC7Bveia64PAqsE5YuQhW4jXwy3kH
	HcEMfgWagwPRh57HaXCi383LmgXgLQtG+Ti8EvrLXFE9jV8CS1N5DCeAP1hBRcIAt8TB47LD
	lHz3h1A9fI2TcTyMeRpjfZZCX0kRIxssCA6W2nh5KELQdKo15ngXejzXWCsSnkS8Co62FJle
	B5WdjigNeD7cnFggHzEfjjefpGVaCd8dUMnqRLB56p7FXrx6nT6G1LY51Wxz6tjm1LH9n3sG
	MTUoQTKb9BmS6Q2DtCvZpNWbzIaM5G3Zeid68vP7wp77rajr0dZuhAWkfk5Zv0WfpmK1O015
	+m4EAq1eqPwky5CmUm7X5u2RjNnpRrNOMnWjJQKjTlB+O+/XL1U4Q5sr7ZCkHMn4dEsJcYvz
	UbKqadmGvNQVi1Kca99eVj5agNNzdlVWnsDb3nqQmjSrQWenwzs2aYo/DaUub98UNg/Ofq7R
	HG4Yi3elf3wk1De8bnD994mrra71Kwa/eu+yInRB53rn4a3ivWL21DdnNn4UXFqX/8FWv7EE
	X5y+Oc+deffljn+3LNl7yKsryPy9fjzXqWZMmdpVr9FGk/Y/FfDcNfUDAAA=
X-Brightmail-Tracker: H4sIAAAAAAAAA02Sa0xTZxiA952eG8S6Y8HwjRA3T4bGW6Fc1pfZdfulZ/6ZzjiNYvSIJ0Ck
	rfa0KsSYAlNCt3hXoBUxOnVchFIRFUGlIFhvVbGYMUo2AeMl0OjYJhvCgLqEf0/yPs+bvMnL
	KlR/UNFsptEimY1iFk+Hk3dG2wOLju40psYXVMeCt6+KhsrAfhpqi2so8Fb20lCU62MgELxE
	wb2XpQw0DTopePA2l4ChUT8F5ZU3CWjNywGfz8VAW30nAU1dC+BR788MlJzopqGxyUtCR8Nx
	GnqqxihoHduPoKCsAUGx7xoBDSOXGfAczifg+as50NLjJ8Hu3END9asgCXtr/0Sw58dhBtrP
	rwbfu3bqq9lC9VAxJRzMH2SEK44AI/h6aknh+9YBSjjd+IIQOu5ZBXdFIS243xxihO7ORlq4
	+ouNFvLu3lQIr/u7SCF4zU8L++oqkFBT5yeXR6xV68wmq0X6JMMkW77g12kgQa1JAXVCUopa
	k6hd/3lCMh+n122WsjK3S+Y4/UZ1xoHSPLT17KydFwb+pWzI/ZEdhbGYS8LuX58hOwpnVdwZ
	hJsLHqLQIAZ7j9moEEfgkU47HZIGEH5wdEgxMYjgdPjp2arJIJLjcSBQyUxICs4Whp86m5lQ
	UUTgf26N0hMWzWmwfcA+yUpOj2+X10xuIrlYXN/XQdoRy87kUrH/PgopM7C3pI+c4DAuHt8v
	uTKpK7i5eOTEo/f8Mc6/6HzPUbirr4w4gFSOKbljSuKYkjimJCcRWYEiJatsSDfICWpZNMhW
	Y7o6zWRwo/GHq28brruM7IMrPYhjET9N6VpjSFVR4nY52+BBmFXwkcplmcZUlXKzmJ0jmU0b
	zNYsSfag5PHbDiqiZ6aZxt/XaNmgSdZoIUWjTdQmfgZ8lNIXn71WxaWLFmmLJG2VzP93BBsW
	bUOnY4q++SmiMKC/NXdV/ykXLN290bzJNfzSNTyvdaz82ePpK4hPxXfdv8fdrYHfxjqqV3/Z
	2/Zkly749eI0T3p42QfzlycdWTjvbctj/TT+W1G193ppu27bd9rCpYt8ubffKLfFuBa3fFi4
	5dCsc07LDvavnObYYJUzKmWJ3H1j398/nJnBk3KGqJmvMMvif2o9hduGAwAA
X-CMS-MailID: 20190221100821eucas1p2ec6440cf2b734261cbddb47321b37fd7
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
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ming,

On 2019-02-21 10:57, Ming Lei wrote:
> On Thu, Feb 21, 2019 at 09:42:59AM +0100, Marek Szyprowski wrote:
>> On 2019-02-15 12:13, Ming Lei wrote:
>>> This patch pulls the trigger for multi-page bvecs.
>>>
>>> Reviewed-by: Omar Sandoval <osandov@fb.com>
>>> Signed-off-by: Ming Lei <ming.lei@redhat.com>
>> Since Linux next-20190218 I've observed problems with block layer on one
>> of my test devices (Odroid U3 with EXT4 rootfs on SD card). Bisecting
>> this issue led me to this change. This is also the first linux-next
>> release with this change merged. The issue is fully reproducible and can
>> be observed in the following kernel log:
>>
>> sdhci: Secure Digital Host Controller Interface driver
>> sdhci: Copyright(c) Pierre Ossman
>> s3c-sdhci 12530000.sdhci: clock source 2: mmc_busclk.2 (100000000 Hz)
>> s3c-sdhci 12530000.sdhci: Got CD GPIO
>> mmc0: SDHCI controller on samsung-hsmmc [12530000.sdhci] using ADMA
>> mmc0: new high speed SDHC card at address aaaa
>> mmcblk0: mmc0:aaaa SL16G 14.8 GiB
>>
>> ...
>>
>> EXT4-fs (mmcblk0p2): INFO: recovery required on readonly filesystem
>> EXT4-fs (mmcblk0p2): write access will be enabled during recovery
>> EXT4-fs (mmcblk0p2): recovery complete
>> EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
>> VFS: Mounted root (ext4 filesystem) readonly on device 179:2.
>> devtmpfs: mounted
>> Freeing unused kernel memory: 1024K
>> hub 1-3:1.0: USB hub found
>> Run /sbin/init as init process
>> hub 1-3:1.0: 3 ports detected
>> *** stack smashing detected ***: <unknown> terminated
>> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000004
>> CPU: 1 PID: 1 Comm: init Not tainted 5.0.0-rc6-next-20190218 #1546
>> Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
>> [<c01118d0>] (unwind_backtrace) from [<c010d794>] (show_stack+0x10/0x14)
>> [<c010d794>] (show_stack) from [<c09ff8a4>] (dump_stack+0x90/0xc8)
>> [<c09ff8a4>] (dump_stack) from [<c0125944>] (panic+0xfc/0x304)
>> [<c0125944>] (panic) from [<c012bc98>] (do_exit+0xabc/0xc6c)
>> [<c012bc98>] (do_exit) from [<c012c100>] (do_group_exit+0x3c/0xbc)
>> [<c012c100>] (do_group_exit) from [<c0138908>] (get_signal+0x130/0xbf4)
>> [<c0138908>] (get_signal) from [<c010c7a0>] (do_work_pending+0x130/0x618)
>> [<c010c7a0>] (do_work_pending) from [<c0101034>]
>> (slow_work_pending+0xc/0x20)
>> Exception stack(0xe88c3fb0 to 0xe88c3ff8)
>> 3fa0:                                     00000000 bea7787c 00000005
>> b6e8d0b8
>> 3fc0: bea77a18 b6f92010 b6e8d0b8 00000001 b6e8d0c8 00000001 b6e8c000
>> bea77b60
>> 3fe0: 00000020 bea77998 ffffffff b6d52368 60000050 ffffffff
>> CPU3: stopping
>>
>> I would like to help debugging and fixing this issue, but I don't really
>> have idea where to start. Here are some more detailed information about
>> my test system:
>>
>> 1. Board: ARM 32bit Samsung Exynos4412-based Odroid U3 (device tree
>> source: arch/arm/boot/dts/exynos4412-odroidu3.dts)
>>
>> 2. Block device: MMC/SDHCI/SDHCI-S3C with SD card
>> (drivers/mmc/host/sdhci-s3c.c driver, sdhci_2 device node in the device
>> tree)
>>
>> 3. Rootfs: Ext4
>>
>> 4. Kernel config: arch/arm/configs/exynos_defconfig
>>
>> I can gather more logs if needed, just let me which kernel option to
>> enable. Reverting this commit on top of next-20190218 as well as current
>> linux-next (tested with next-20190221) fixes this issue and makes the
>> system bootable again.
> Could you test the patch in following link and see if it can make a difference?
>
> https://marc.info/?l=linux-aio&m=155070355614541&w=2

I've tested that patch, but it doesn't make any difference on the test
system. In the log I see no warning added by it.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

