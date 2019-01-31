Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA445C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:08:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B29B32086C
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:08:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B29B32086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A3B78E0003; Thu, 31 Jan 2019 14:08:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 454C28E0001; Thu, 31 Jan 2019 14:08:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3912D8E0003; Thu, 31 Jan 2019 14:08:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E39A68E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:08:00 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id y6so3287559pfn.11
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:08:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NuHG6r+UFIFQiNu07/sCbrHergi71Fuzu2f7cnyC5pE=;
        b=MQXYVfPNELE9mrs2TCzQHZPr2wuKhGDfPPnl+mBP0PtPHhEI4pYqabnItUugVf3r7p
         +X0UO2GHt7oF7xz/dUF8MpPPe3K2wuszIMsMjgWBZGELac5sny2X11kHksSGzKoQy5dP
         cEgWENhHfx2RvJTe7GgHNjkbD0bZleQ2EJLWvFvdRfMc1fgpgXZXTRik2Wuo5+WBfQw2
         VZ0g0t0SiWECX8n1IfF4k0b/Uz/8qGJMKAL6VDfEOK5F+reNS38Rm+MMTSqHbeSEEs6H
         coP8g6CqW1ZFV3+4++1Ghh7WFmgRO79MSHZZnNWEeCBFLGjP7xShVVd8iXPuJ4BAvJn0
         ZPHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukeb7euk8ubJUnik3QtM2VlszxxSEDCPH0mNxSa44rYUE3x2tV2C
	0R8ubnK+QYCGZTbZC5OiwiL2HTfqxEsfh0DJTTO66wR0gPlXX9WlmP2r9HiY3+fa6bcgO4YSi+J
	xgKy6Pj2qez0HYrXF4My12vBA8fQQf3I6rdUm9xwQQL6iOKcu8Ud0GonyiyNH1+f9Cg==
X-Received: by 2002:a17:902:6f09:: with SMTP id w9mr36851663plk.309.1548961680598;
        Thu, 31 Jan 2019 11:08:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4pyu7qjzx0zPn+F7Iwj5ytgjQRHR8maueyf+3qhUftJFa/lrv1oOiewTBEVjT739r9HyZu
X-Received: by 2002:a17:902:6f09:: with SMTP id w9mr36851621plk.309.1548961679949;
        Thu, 31 Jan 2019 11:07:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548961679; cv=none;
        d=google.com; s=arc-20160816;
        b=G/fieU9iiqGjiGBfiSumlsoQqQfKcGCCSV5KMnxiYFoTSCb8OzexSQjF0LAx7EG04T
         6Jm7tBHapcisBobKvahdOz6JtEANyQLH+70xMonloem/KWHlFmE8eSN40PN39gE/bHY2
         /EaGBIf8LGBWgrSMMNBAqiMkD17rcmG63sojHHLqP/99JqgKjOCWhzQqgdUFOE2I2sjf
         LoQYBewA6lJLQpQyKLx7GRLIevbxuOyGkSZWlTqfPYapMC9CKAW5HHhKg8lUEukZ3rz2
         w7cZcAngJmGAegpAqdOAPycleZFCnSjFQxTVSDobFTz+7XYyD9Xi1BYPxDsP5o9GVs4m
         Br5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=NuHG6r+UFIFQiNu07/sCbrHergi71Fuzu2f7cnyC5pE=;
        b=KQrfaullIlhjnrQ2wVD1aWP9F7VRTBWpZdy+/gKQZnM5KQKrC5V7NFfruQDHCykiJN
         QDRtCW8lyeiMCv9+sXlrq3y6fQ8K/fwEISO27Jn1mveqmPtQdTizjSyu+7QvoftxJbjJ
         XbPA6PuN0p6PB6Cdx0Xb4CvDAdWuf/+rSFqH+mpI8yeYJrP/+je+IMN+COB2uK+QWmPH
         UeLhCuLBcJ7VB7odYwRpLjcI9/b19AEOh294VHQDqpTkPobbdAJIt5y0Or8yusSUbBi5
         in3FANtVySM/66UFREc8DiXjFjueTTuCuZ1IlFAeRHk5Swu6QiDd5d1ic9MNm+Vtc2wR
         khGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b30si1083645pla.285.2019.01.31.11.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 11:07:59 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 300FC4598;
	Thu, 31 Jan 2019 19:07:59 +0000 (UTC)
Date: Thu, 31 Jan 2019 11:07:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: Chris Down <chris@chrisdown.name>, kbuild-all@01.org, Johannes Weiner
 <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [mmotm:master 203/305] mm/memcontrol.c:5629:52: error:
 'THP_FAULT_ALLOC' undeclared; did you mean 'THP_FILE_ALLOC'?
Message-Id: <20190131110757.6b975f1e787dc7adf414a162@linux-foundation.org>
In-Reply-To: <201902010206.hcZ8gj0z%fengguang.wu@intel.com>
References: <201902010206.hcZ8gj0z%fengguang.wu@intel.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2019 02:57:08 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   a4186de8d65ec2ca6c39070ef1d6795a0b4ffe04
> commit: 471431309f7656128a65d6df0c5c47ed112635a0 [203/305] mm: memcontrol: expose THP events on a per-memcg basis
> config: ia64-allmodconfig (attached as .config)
> compiler: ia64-linux-gcc (GCC) 8.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 471431309f7656128a65d6df0c5c47ed112635a0
>         # save the attached .config to linux build tree
>         GCC_VERSION=8.2.0 make.cross ARCH=ia64 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/memcontrol.c: In function 'memory_stat_show':
> >> mm/memcontrol.c:5629:52: error: 'THP_FAULT_ALLOC' undeclared (first use in this function); did you mean 'THP_FILE_ALLOC'?
>      seq_printf(m, "thp_fault_alloc %lu\n", acc.events[THP_FAULT_ALLOC]);
>                                                        ^~~~~~~~~~~~~~~
>                                                        THP_FILE_ALLOC
>    mm/memcontrol.c:5629:52: note: each undeclared identifier is reported only once for each function it appears in
> >> mm/memcontrol.c:5631:17: error: 'THP_COLLAPSE_ALLOC' undeclared (first use in this function); did you mean 'THP_FILE_ALLOC'?
>          acc.events[THP_COLLAPSE_ALLOC]);
>                     ^~~~~~~~~~~~~~~~~~
>                     THP_FILE_ALLOC

Thanks.    This, I assume:

--- a/mm/memcontrol.c~mm-memcontrol-expose-thp-events-on-a-per-memcg-basis-fix
+++ a/mm/memcontrol.c
@@ -39,6 +39,7 @@
 #include <linux/shmem_fs.h>
 #include <linux/hugetlb.h>
 #include <linux/pagemap.h>
+#include <linux/vm_event_item.h>
 #include <linux/smp.h>
 #include <linux/page-flags.h>
 #include <linux/backing-dev.h>
_

