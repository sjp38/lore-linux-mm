Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75CCBC76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:53:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37B33223A0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:53:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37B33223A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF7276B0003; Tue, 23 Jul 2019 01:53:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA7488E0005; Tue, 23 Jul 2019 01:53:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A49368E0003; Tue, 23 Jul 2019 01:53:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8676B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:53:52 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 91so21293995pla.7
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:53:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=Y/zml0Bmqj+dMrviRHdA161MJMflzVlVIfgMq4IsxGM=;
        b=hTubsMmZCvAbsmSXjafBeTna8Djg0NQ0h8ByPRFE5adDPwQZFpRCu5t+CA2jWL32E1
         2qsQSKTEvKMrH87buToZlWC87nwNo0CMsxqfO9U3zi45jJ4n8isBbwO3nUWrc5Vzk29h
         lTeB9vl+GnnUQV3Mw/ZfyAE4P/YDpWM0/QtWSJVb10vedxxUSSZ9OKba2HScgkOVpavT
         O0whpIS2AEaSnfod1nplaUZb3AdSGwpz5cK1HR8nGVWWOm1/YGqPiYvn/NF0a6zA0vIQ
         ChZ4q4GIyBiDlKvofGCOgCUNXCPIk2MW/TecP5tMFQgPk6JkoawSgunIkM7yqraS//Dg
         j+LA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
X-Gm-Message-State: APjAAAWNmTkQAZBTGgA+e+V5Du1ri4qu00C4Hue34QekLHfWda5DdiAu
	LAPaLpl6Xw0U+KAgqo2iG8EibhpgJ0D+8ucz7yC3FqF0W1KnDeXgmKy9xFhZkYU2sI5r5oaN3FE
	ZQYkVnJfmZEqcAQH/Gwa0r4jYDH1lixVHvLKaUpLJh0Ru9z9QlKnXynYVpiFd4lfz8g==
X-Received: by 2002:a17:90a:d814:: with SMTP id a20mr80944209pjv.48.1563861232088;
        Mon, 22 Jul 2019 22:53:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxc56n0PPC8mMOB2ag4f02VXa2X0BkOJJetplN57C6hle5YbQ34N3t/XkwEU1qlXYCZl2dv
X-Received: by 2002:a17:90a:d814:: with SMTP id a20mr80944166pjv.48.1563861231251;
        Mon, 22 Jul 2019 22:53:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563861231; cv=none;
        d=google.com; s=arc-20160816;
        b=BLn3W0FwdER2QGvBgM53c++fEJo1WiNfM98U9SgheCsiUJZ6D4RZjkEWLbpisYYiOr
         csGVwFx3hr/wnqQLkc4duDkl7olCs1mEV4ZU6e/ihAcnSITybpXZKN0y7OmNVD8eaYW2
         DYn2xurIOOlk3L00Cj3Djxx7aFdvEmDKl7yVIr1xJekC2+bV3ZbvjSpp4kbmt/Vq+Rdm
         ygVWkL4f6dUvAQJXnBuMN8pf/JwFCND7ipcp5y1EFb7oaEdgK3HB1+5kZvMfPYEgkm0O
         rgyDAaya5tCU/3K95AeJhtphOIQF8TXG2JpE+iKzj9fjof275G6JSsfP5HMKjXFsjYLA
         AaCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=Y/zml0Bmqj+dMrviRHdA161MJMflzVlVIfgMq4IsxGM=;
        b=AVZvtRO9y0slVwXok2gEW2vlRe3wZDLg9Qu8m7ixcyfbtSdDL0+ujnyZlOzqVPx/mE
         b3LggprcqeUZXCcg1tQBLbCKh0e1mNtAjUBf7jIbF3g8jTgcGdun5dR1FOD3ioE+gbhn
         2iO6rhgTyJws1QzMfwsl2P0wRPllWC2jzVNZHE6J7buVJylTzjgYHWbHEFFTtgMKggFY
         blKc9kmu6mf6IvaCMi07BzknxaQbVCyLpnn05Jv16KR/YNFUaPauEJrFMf+1decUo7su
         MYKbn/q8yU9YmnoOOqe7iT0GeXxO+hgDpp8C2vyJ9FFssojMPaOf1gEob0yDxUF2ggdM
         kLRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id m4si11670917pgv.57.2019.07.22.22.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 22:53:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id D4A5E6E6D5A9386D9C48;
	Tue, 23 Jul 2019 13:53:49 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.439.0; Tue, 23 Jul 2019 13:53:42 +0800
From: Hanjun Guo <guohanjun@huawei.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton
	<akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, "Jia
 He" <hejianet@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Will Deacon
	<will@kernel.org>
CC: <linux-arm-kernel@lists.infradead.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>
Subject: [PATCH v12 0/2] introduce memblock_next_valid_pfn() (again) for arm64
Date: Tue, 23 Jul 2019 13:51:11 +0800
Message-ID: <1563861073-47071-1-git-send-email-guohanjun@huawei.com>
X-Mailer: git-send-email 1.7.12.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.102.37]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here is new version of "[PATCH v11 0/3] remain and optimize
memblock_next_valid_pfn on arm and arm64" from Jia He, which is suggested
by Ard to respin this patch set [1].

In the new version, I squashed patch 1/3 and patch 2/3 in v11 into
one patch, fixed a bug for possible out of bound accessing the
regions, and just introduce memblock_next_valid_pfn() for arm64 only
as I don't have a arm32 platform to test.

Ard asked to "with the new data points added for documentation, and
crystal clear about how the meaning of PFN validity differs between
ARM and other architectures, and why the assumptions that the
optimization is based on are guaranteed to hold", to be honest, I
didn't see PFN validity differs between ARM and x86 architecture,
but there is a bug in commit b92df1de5d28 ("mm: page_alloc: skip over
regions of invalid pfns where possible") which has a possible out of
bound accessing the regions as well, so not sure that is the root cause.

Testing on a HiSilicon ARM64 server (a 4 sockets system), I can get
pretty much speedup for bootmem_init() at boot:
    
with 384G memory,
before: 13310ms
after:  1415ms
   
with 1T memory,
before: 20s
after:  2s

[1]: https://lkml.org/lkml/2019/6/10/412

Jia He (2):
  mm: page_alloc: introduce memblock_next_valid_pfn() (again) for arm64
  mm: page_alloc: reduce unnecessary binary search in
    memblock_next_valid_pfn

 arch/arm64/Kconfig     |  1 +
 include/linux/mmzone.h |  9 +++++++
 mm/Kconfig             |  3 +++
 mm/memblock.c          | 56 ++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c        |  4 ++-
 5 files changed, 72 insertions(+), 1 deletion(-)

-- 
2.19.1

