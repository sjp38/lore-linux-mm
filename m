Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEB7CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:09:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81DDC20823
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:09:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81DDC20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1633B6B0008; Tue, 26 Mar 2019 04:09:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 112C36B000A; Tue, 26 Mar 2019 04:09:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0016A6B000C; Tue, 26 Mar 2019 04:09:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5B266B0008
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:09:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n24so4867009edd.21
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 01:09:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc:from
         :subject:message-id:date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=GpopsNz3+w9OTqDe9FbB0oB0zsjzWRvXSvff+EndW5M=;
        b=inMn+LKUH6J2As7v+/oUn7DHhnwNG6iJ4W31bagyQ6Ozq8SXEKMbiLK0eZ3D5OQVFc
         Gf6nnAS/knyo4Ms4zoPJO/BCKgRvkXZeyOkXIi/inRHAwh5btERGJz2FAFtDbQFSMhN7
         RIESpP17yl5cW8bNz6EhWlNkxH2JtovpKVksPAH8Ej7kLMIhu+A96TXCNu+MYBXj7zvA
         VuiTuGJ5fjGUhcouC0mpgv4Ta6fB702Pwl7jHnaJ+7F77UpJXbv3ZHJxIoIFKc1o9RFB
         TRcBMoCi51hFebLZu8PXHkWSU2BJ8Wz1h3PlRtNZPSJb1Mi8pJLPLCd25Tb2IY/FYGhF
         6Wpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUjwGfcGDKjWZkSDwhBMsfNekQV8FdxnZq1t4d/G0q6m1KPF9zi
	hdavYVZq39wg+pKKeM3c69E7RDhMQ51vnl8Df6fNbiqp5JJF8ME7kNFtoGw+wXgk0mq+4fGBbEh
	hcWd9dABcP2iVmYh2c+AaVbAgN/LSB65lp3fwM2TrPephDgBPWY9XcH7y3iSnucXnXQ==
X-Received: by 2002:a50:b1fa:: with SMTP id n55mr19401148edd.34.1553587761201;
        Tue, 26 Mar 2019 01:09:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPl8nBL80/vVyD0NHeMKBk1LWnt+/oBrZhBER4Ggx/iiOhOafeiE6JI9sA1LNo8htROnau
X-Received: by 2002:a50:b1fa:: with SMTP id n55mr19401089edd.34.1553587760108;
        Tue, 26 Mar 2019 01:09:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553587760; cv=none;
        d=google.com; s=arc-20160816;
        b=awxICO6110UAMX8eg5mXuZUQBiul1r0ZB56IEIvmms2HKENckrkEiszsBNPrpORclI
         +CrvepbBcAM2j5dBSdx3OeFPDuhF/ysXloqiVqCfdH4Qb6wiTPRgWMaKKYbY9GR8Llhq
         8vy/wxuOX5XJ6xtXnFahZeSQRX5rMC59KlPKIPyS6LFKLEseE4SoX8oz7byaCUEBBAeV
         unaEUuTcthkhhTsg5l+UiRFP6PIXedNbI3Pu6qfQf8g9CpC5P+zl6VmaITCWTMEug1PQ
         j7tjnQ91d+9djdtq1SHMx+VteF6wL9Fuj/q72g+B+7oOJkAU9FZa5DiD1dbdtXR77hBl
         AslA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:from:cc:to;
        bh=GpopsNz3+w9OTqDe9FbB0oB0zsjzWRvXSvff+EndW5M=;
        b=UfpslyCO7Z9t3R4tAzHgXvvRPyHFnqC531hYe/+sYB+j8yYpbbcvDhm0/Jz7V0L1Ky
         3iEcRk6GNWVL+T48jkqyxmTj7TF1dS/Q+/xjL419xUuFfaRH4WVq+PelJlNbeUCGCWZg
         quIGU2r7KKzygw2h87WY+UAWXB3alHRWAPkQTm+vPmCtEkbOZTsrIq/G+NSvsE+8Iafg
         wp5idoTQ+07LcH2UhHSiHQ/rpLWN2UD1sN5sDvgYDBYO5zBa4Teho4+CnDjqnBmcz6uh
         XnIJyUn0DIGzvmGnAL/WdZMk1qinzkbcMkcI55IMF1XdpWuZ6c4Kr22+Tus+ZmeBU/sr
         v8VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k51si1704817edd.266.2019.03.26.01.09.19
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 01:09:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D414F1596;
	Tue, 26 Mar 2019 01:09:18 -0700 (PDT)
Received: from [10.162.41.160] (p8cg001049571a15.blr.arm.com [10.162.41.160])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 803443F614;
	Tue, 26 Mar 2019 01:09:16 -0700 (PDT)
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Vladimir Murzin <vladimir.murzin@arm.com>, Tony Luck <tony.luck@intel.com>,
 Dan Williams <dan.j.williams@intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: early_memtest() patterns
Message-ID: <7da922fb-5254-0d3c-ce2b-13248e37db83@arm.com>
Date: Tue, 26 Mar 2019 13:39:14 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

early_memtest() is being executed on many platforms even though they dont enable
CONFIG_MEMTEST by default. Just being curious how the following set of patterns
got decided. Are they just random 64 bit patterns ? Or there is some particular
significance to them in detecting bad memory.

static u64 patterns[] __initdata = {
        /* The first entry has to be 0 to leave memtest with zeroed memory */
        0,
        0xffffffffffffffffULL,
        0x5555555555555555ULL,
        0xaaaaaaaaaaaaaaaaULL,
        0x1111111111111111ULL,
        0x2222222222222222ULL,
        0x4444444444444444ULL,
        0x8888888888888888ULL,
        0x3333333333333333ULL,
        0x6666666666666666ULL,
        0x9999999999999999ULL,
        0xccccccccccccccccULL,
        0x7777777777777777ULL,
        0xbbbbbbbbbbbbbbbbULL,
        0xddddddddddddddddULL,
        0xeeeeeeeeeeeeeeeeULL,
        0x7a6c7258554e494cULL, /* yeah ;-) */
};

BTW what about the last one here. Most of them got moved from x86 through the
commit 63823126c221dd ("x86: memtest: add additional (regular) test patterns").

- Anshuman

