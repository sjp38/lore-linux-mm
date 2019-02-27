Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E875C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 20:47:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CF0321850
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 20:47:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="X0dP0ili"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CF0321850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0BFB8E0003; Wed, 27 Feb 2019 15:47:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBBB18E0001; Wed, 27 Feb 2019 15:47:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD1F98E0003; Wed, 27 Feb 2019 15:47:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9328E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 15:47:24 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id i2so14304546ywb.1
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:47:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=fysy4W1JsLJNGtNiqBcR+gaIGLkCCRdCGseNbvSiG5A=;
        b=AWiZ/4m5yILfoVxQf14subl1XE4u3RKF9TlEyLj1r95UbemNsCuRO75JPxNp2IdtOs
         umW8ntXVE42w8bGsX4DU6IGFQTYQrKm7Q4rEnjdidR9aYBX9SrmEst9cBsjXva+ZksDs
         nEZsd+bIvZ2P7x1vhBTFLK2TMMhU8wZCsHYJjYj6FsNP+irRXtN34YJzZHoc7ar7+coC
         FxAbgwe+yyQS2Xbx80gGLhw5Fg/2pbXdzkD3sXeq3Y82HbOM59eg9SvTstVAoKMX+vw5
         CHxARolrj93vFSibs/SX62Z/bqjIby5Jegus/eCHOET7xPAB/2MCk4KADI0c5ax+JmMl
         W/7w==
X-Gm-Message-State: AHQUAuZ8lxXhAfsymgXFoh2HceugQ0/R77ofAcBDww0f9C33skpUjcsE
	qZeblut3kObTfFuKdgAT2AMCFQQRjHbPUlSQcXY7I7xDoEYgaqxxFXkq2C30gYsR90zFIUK0vnR
	HRLcpswQKDBffHLZsYrQljJY4xN2taJ6WFO8w8OuZ/BA6LTEWtTEHDTTTEuBy9/U9mA==
X-Received: by 2002:a81:4ed6:: with SMTP id c205mr2802943ywb.13.1551300444274;
        Wed, 27 Feb 2019 12:47:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaIvllgghGhYWcP0gSprWEb9AMgBNCDYlGp5YkWvoUewt/7kOqDHfb1mo2fgAqnTSSkclVL
X-Received: by 2002:a81:4ed6:: with SMTP id c205mr2802899ywb.13.1551300443323;
        Wed, 27 Feb 2019 12:47:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551300443; cv=none;
        d=google.com; s=arc-20160816;
        b=Ys0qYspTlN4LClVcuy4tQRTDAIfQsV1vn/ckqMz7JlNSPfn4x7WGGmvN3ELc9l3WdD
         aZZ6zbHS0s98v5f9aWSrTpWVAfD2ILFsVvujONTq9FsVc/MMLQOEDnX9wbP6O7GQykFF
         ddU1pnII7mm7blETqpffjeH8JFCX8A1+0dSWnE4ZuMW07+P42l8YYYitG8/geKUsGcpv
         A1PvHrJO9edBKP8ZijifKeGzQoNuclkyQaqGm5xq2dY3l16u6b2aOEAPM4cogvkQEbmz
         ye3DMyCzvWL2YhC4xwKHYLqNjXNVbSDd/Fi3MO0UAi3GYwzAGZlIBXMlyh0nOkb4bq1R
         hF1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=fysy4W1JsLJNGtNiqBcR+gaIGLkCCRdCGseNbvSiG5A=;
        b=fdk0guPhPQLczJeBUith+OR1b19dYHBjNtHB+u4/Dg86TtcnFJnAe9u8eUxJPBmKX3
         0LFBdu+ulp+Ru5e9+mCebjJ/O2eVwKnSHTx4Uwd2rhHDmCAgXqwsZtqIcD1xfBzm6N4i
         n9HcEct544S9PBHo56lT3L9/YWYQDEgLRQmjop6xo+eLAdJRQdTePWI5SaPR4YoFnt0M
         Q9NvCryQwjsxLTMiuhXrq3xNp8DAQDEyUHCEp6Gh7hwAqndqeKid7driCy42Rf2xFMYB
         FUzYS6I/UYh/d3FQyZUyYG0Cy6HBzhfJVnqRgAwYPMLELsTTPogykkZexxTrOoFJpPq6
         ssgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=X0dP0ili;
       spf=pass (google.com: domain of jonathanh@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jonathanh@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id j125si9268124ywb.159.2019.02.27.12.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 12:47:23 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathanh@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=X0dP0ili;
       spf=pass (google.com: domain of jonathanh@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jonathanh@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c76f7630000>; Wed, 27 Feb 2019 12:47:31 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 27 Feb 2019 12:47:22 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 27 Feb 2019 12:47:22 -0800
Received: from [10.26.11.186] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 27 Feb
 2019 20:47:12 +0000
Subject: Re: [PATCH V15 14/18] block: enable multipage bvecs
To: Marek Szyprowski <m.szyprowski@samsung.com>, Ming Lei
	<ming.lei@redhat.com>, Jens Axboe <axboe@kernel.dk>
CC: <linux-block@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval
	<osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner
	<dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike
 Snitzer <snitzer@redhat.com>, <dm-devel@redhat.com>, Alexander Viro
	<viro@zeniv.linux.org.uk>, <linux-fsdevel@vger.kernel.org>,
	<linux-raid@vger.kernel.org>, David Sterba <dsterba@suse.com>,
	<linux-btrfs@vger.kernel.org>, "Darrick J . Wong" <darrick.wong@oracle.com>,
	<linux-xfs@vger.kernel.org>, Gao Xiang <gaoxiang25@huawei.com>, Christoph
 Hellwig <hch@lst.de>, <linux-ext4@vger.kernel.org>, Coly Li <colyli@suse.de>,
	<linux-bcache@vger.kernel.org>, Boaz Harrosh <ooo@electrozaur.com>, Bob
 Peterson <rpeterso@redhat.com>, <cluster-devel@redhat.com>, Ulf Hansson
	<ulf.hansson@linaro.org>, "linux-mmc@vger.kernel.org"
	<linux-mmc@vger.kernel.org>, 'Linux Samsung SOC'
	<linux-samsung-soc@vger.kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>,
	Adrian Hunter <adrian.hunter@intel.com>, Bartlomiej Zolnierkiewicz
	<b.zolnierkie@samsung.com>, linux-tegra <linux-tegra@vger.kernel.org>
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <20190215111324.30129-15-ming.lei@redhat.com>
 <CGME20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d@eucas1p1.samsung.com>
 <6c9ae4de-c56f-a2b3-2542-da7d8b95601d@samsung.com>
From: Jon Hunter <jonathanh@nvidia.com>
Message-ID: <0dbbee64-5c6b-0374-4360-6dc218c70d58@nvidia.com>
Date: Wed, 27 Feb 2019 20:47:09 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <6c9ae4de-c56f-a2b3-2542-da7d8b95601d@samsung.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551300451; bh=fysy4W1JsLJNGtNiqBcR+gaIGLkCCRdCGseNbvSiG5A=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=X0dP0iliVFercVqWdMyW/NR2Nhm0eLApUzdqUyISSWUx2H+DKhUu/OKtqWe2+3ZuT
	 au4eOklUFmE4Gr2obXchzT8IXOfMhcyX4FkEsLxzHW0xgKT/h6CV7784HRm5efp90O
	 La7tft6R64o+psxbqoi6GCRY4KpDinbyuM578z8ZIBlOABzOuvOkGz6q77lXYGVw0F
	 i4IUbygeJkCCpZ0U5/kCdyLBwxOPIqZvceHCPKG8aMbmcU8ubwJyoq9ClYgVHYmDHM
	 dxcWgdcM3oW54O+MFPY5/ZPt1Zh31nOGXIQBPU0L01WBNStNQbbLPLk/T1RrJziyxj
	 hseLr65aHTomg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 21/02/2019 08:42, Marek Szyprowski wrote:
> Dear All,
> 
> On 2019-02-15 12:13, Ming Lei wrote:
>> This patch pulls the trigger for multi-page bvecs.
>>
>> Reviewed-by: Omar Sandoval <osandov@fb.com>
>> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> 
> Since Linux next-20190218 I've observed problems with block layer on one
> of my test devices (Odroid U3 with EXT4 rootfs on SD card). Bisecting
> this issue led me to this change. This is also the first linux-next
> release with this change merged. The issue is fully reproducible and can
> be observed in the following kernel log:
> 
> sdhci: Secure Digital Host Controller Interface driver
> sdhci: Copyright(c) Pierre Ossman
> s3c-sdhci 12530000.sdhci: clock source 2: mmc_busclk.2 (100000000 Hz)
> s3c-sdhci 12530000.sdhci: Got CD GPIO
> mmc0: SDHCI controller on samsung-hsmmc [12530000.sdhci] using ADMA
> mmc0: new high speed SDHC card at address aaaa
> mmcblk0: mmc0:aaaa SL16G 14.8 GiB
I have also noticed some failures when writing to an eMMC device on one
of our Tegra boards. We have a simple eMMC write/read test and it is
currently failing because the data written does not match the source.

I did not seem the same crash as reported here, however, in our case the
rootfs is NFS mounted and so probably would not. However, the bisect
points to this commit and reverting on top of -next fixes the issues.

Cheers
Jon

-- 
nvpublic

