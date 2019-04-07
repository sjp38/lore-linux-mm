Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17604C10F0E
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 19:08:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B004C20880
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 19:08:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kxrAwGML"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B004C20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03E496B0005; Sun,  7 Apr 2019 15:08:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2E7A6B0006; Sun,  7 Apr 2019 15:08:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF65B6B0007; Sun,  7 Apr 2019 15:08:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A031A6B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 15:08:45 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id p11so8364561plr.3
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 12:08:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=G2HuIUYt3N6lA/ZPrsORZs6jP51jn2gGYsgbLEWVEXc=;
        b=Ro//TRsn7sIn1lCAHIu6+GuklL/d6t6CFYs5m/vf46OcOgV/uo5PHpwKNZzHltmQ8+
         VofMGBbnLpDvIvF8RtvgZo6Y7LYstdnwuPpN2qcC9zWVC7TdHwHhxbsxM2xdujXj9rGd
         8EAlsWD6h9NULQ+d+2A49c2Yqyzx004IIGzGPoVYpKk2tB9mSig2lxCrK1V/7wq7XwjA
         uhvExj7LMDXXtnZwbK3vcVoSCXWIcF7ROcvUeZuHIAW0INYDvbltAw50XLPCQk4GA+Hg
         PFmhsF7J2vBzy1XjEbCUDs2c7EDzXGuhVsmsXr3IKCtDhyL8uO7CivnZmIXxiiHtOp8A
         Ev4Q==
X-Gm-Message-State: APjAAAXLq+yiBlijki87qnt8NMDJgGGoIs555/Z04xfw2TUeDs/mkqfg
	9FsJNTEblJ1gTiL0chOT5zn1WvwOvRgrjW+W6jNPpEGf4HrDHk1ZnOYV/DnG49TsQjec+USn1ww
	CZYxEhQSoMUZSvzlb7UMbmrcDWbfJ+oZSIeoyf3ESSc99Mle3sk/HU/XFnaVlpoLvPQ==
X-Received: by 2002:a65:638f:: with SMTP id h15mr20387728pgv.147.1554664124945;
        Sun, 07 Apr 2019 12:08:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj4O57YtwOCM/RXyrGwq5WHrFyWDe2JUOYclXTx7Vi0wsnJuPz9Ga+05mqL3XkbAhagkTN
X-Received: by 2002:a65:638f:: with SMTP id h15mr20387675pgv.147.1554664124044;
        Sun, 07 Apr 2019 12:08:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554664124; cv=none;
        d=google.com; s=arc-20160816;
        b=Dz3VH6wGB8zGe9doXCS7NvVRkPKnJ2oaHjbjIUdUKYq0IqznYWAF4wofi209asJCl/
         I008ZpSO0jbMFfjHv9v6fiJyLce/DHIVYzslE1rjXryhXlqjdi8TXku0xSqS4sWhsoQ4
         5NSdnyHiCAXUPzBxJ2WQVW6xNbiKorgzZ6mrew4ZqZaDsOx/vJ2jb/MO/UNeTms/hhhq
         bSvlRHza79ebZbKCyRHEYO7cId1yRPPWJANgaXWl4673iwFrcyaA7veI6pOTyNJbK9sG
         vbGYY6mgvlpFltePvv0BtLjyVlaiyn/+l34hVjX1kpPaUOGuMMJ9N2wZtrSFpbZEfGqJ
         FBPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=G2HuIUYt3N6lA/ZPrsORZs6jP51jn2gGYsgbLEWVEXc=;
        b=yRtn0HCs54RiLETI6+kDyQruoGcOr2dLog6sE3oU8GwL5Lwo1iG6LZtFAdXdFDbFSV
         VFY9VKjsLrtKjBCLstujiMud3BE3e4xVpALkEpVgelAipiEi+Y8BOfg8l8ePOeXHW0E3
         h1DlVpnkKjc0lT28rTvH928USultK7thSRakaEbwijPvmqjus4sSjAF4fUVilkPPUHRf
         vp8Asv0hK8O92U2FiidUnvcLC8sEnjwtvQOTw/u8q5dDc0WnN0bMb8YFwabgU6N6IoKs
         WEuIu+ZTFChf7BFxROxWkC5z9AtWzFG4Pagsdbc4+vqNR3S5yVww+yP84Gubg4PXkeYA
         kvsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kxrAwGML;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i3si24837954pld.129.2019.04.07.12.08.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 12:08:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kxrAwGML;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=G2HuIUYt3N6lA/ZPrsORZs6jP51jn2gGYsgbLEWVEXc=; b=kxrAwGMLKBNXLYQzFWySNWrWl
	hF9cL9d1h0qdGQXozGq5f4pn30JePgqze2BgU2eiYKekbKgaPCBVXksK1I+8njhZ3ZKkOXpaWDSuv
	a/GuAWC6Ih+bsonaZL+MfNjlquvHfNyKKMjJVaVAzjVyW2PhWd8/uYSnu7BRanksX1DOHHiB4whxn
	vfiunzzkNw52DiXWgxpJddCmXEmyA26PgFn9L3MxoaYKT4peTP0wjGfdlRfl80xOvmRW9FKf7pntU
	XHSbToe02RZZMoRg6lNhkkzW4UFk371LZRygQ5ytWbYLey1jntLyFN6pBs9DXRvN0jKzlHdqGyVeu
	CKgPubNCg==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hDD9l-0001ZG-Fe; Sun, 07 Apr 2019 19:08:41 +0000
Subject: Re: [mmotm:master 227/248] lima_gem.c:undefined reference to
 `vmf_insert_mixed'
To: kbuild test robot <lkp@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>,
 Manfred Spraul <manfred@colorfullife.com>,
 Johannes Weiner <hannes@cmpxchg.org>, lima@lists.freedesktop.org,
 dri-devel <dri-devel@lists.freedesktop.org>, Qiang Yu <yuq825@gmail.com>
References: <201904061457.ZCY5n0Jo%lkp@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <c71215b3-8a6a-a4dd-b9bd-9252bd052a32@infradead.org>
Date: Sun, 7 Apr 2019 12:08:39 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <201904061457.ZCY5n0Jo%lkp@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/5/19 11:47 PM, kbuild test robot wrote:
> Hi Andrew,
> 
> It's probably a bug fix that unveils the link errors.
> 
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   b09c000f671826e6f073a7f89b266e4ac998952b
> commit: 39a08f353e1f30f7ba2e8b751a9034010a99666c [227/248] linux-next-git-rejects
> config: sh-allyesconfig (attached as .config)
> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 39a08f353e1f30f7ba2e8b751a9034010a99666c
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.2.0 make.cross ARCH=sh 
> 
> All errors (new ones prefixed by >>):
> 
>    arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
>    drivers/gpu/drm/lima/lima_gem.o: In function `lima_gem_fault':
>>> lima_gem.c:(.text+0x6c): undefined reference to `vmf_insert_mixed'


vmf_insert_mixed() is only built for MMU configs, and the attached config
does not set/enable MMU.
Maybe this driver should depend on MMU, like several other drm drivers do.


Also, lima_gem.c needs this line to be added to it:

--- mmotm-2019-0405-1828.orig/drivers/gpu/drm/lima/lima_gem.c
+++ mmotm-2019-0405-1828/drivers/gpu/drm/lima/lima_gem.c
@@ -1,6 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0 OR MIT
 /* Copyright 2017-2019 Qiang Yu <yuq825@gmail.com> */
 
+#include <linux/mm.h>
 #include <linux/sync_file.h>
 #include <linux/pfn_t.h>
 


-- 
~Randy

