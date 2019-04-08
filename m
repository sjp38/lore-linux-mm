Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEC9AC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:44:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9835220883
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:44:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gnGCe3xj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9835220883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2855E6B0279; Mon,  8 Apr 2019 00:44:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23D7E6B027A; Mon,  8 Apr 2019 00:44:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 124A86B027B; Mon,  8 Apr 2019 00:44:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C51026B0279
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 00:44:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h15so9234994pgi.19
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 21:44:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0pfBnB60nfaq0Lris59bgawiBT3Gg1IQEoag+3VPJ9A=;
        b=X2dpZHHwz9rOj4tQTp0N+YHeyemdb9TGvY74navrEg1ZWjAnKaIWVXEcBs1bBgucC6
         DfbjLNqpWYWccNOtkrQZnu96LYeOjmjyRiS7OOaTx7O8OHxTR5E28c07TR2huFuVt0sW
         coHHsk3EmeNyF1RsJ9vqKipKu5uNcNoKQ24zMWdpB1uBjZPPiLIdMToFzywW41mXWv0w
         nEbINwHegLZSvdmZBZjynt+5/tgfRs9lS5/6gp7IxAupr1LqwIva6npgA10sJJn1L3Q/
         JLPZ9aWXBYgERYVzsb+ndo399L5c8JNbywFDBX8uoQbzfmbj5wbBVzSKTaKOhmLul1dd
         tKXg==
X-Gm-Message-State: APjAAAU7JkUlvvYhknzdOokNVGtTCo4phe2w/grJlEMMrZDb4DsLbll4
	sZPD+U1Cu0eHuHBUrYKb9YySxlNXNYNpF17Ip8tAxpgS4w5s7kT0EkLxxoufEKjDfWpNtfwbln3
	BiwIxp/IPJx6jzvJJkcTd2cP+V1ZNOlVJDWUu17fhNG6g7dTx/b/BYxum/YGDmg4H6g==
X-Received: by 2002:a17:902:ea0d:: with SMTP id cu13mr27742216plb.92.1554698664269;
        Sun, 07 Apr 2019 21:44:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjpaZyYw9r2ZZ2beptZXwR6H/JdjMwCrSWxEn6qEFWkqpokZ6q/jtG7wMlvdJrLAeLuCMC
X-Received: by 2002:a17:902:ea0d:: with SMTP id cu13mr27742161plb.92.1554698663042;
        Sun, 07 Apr 2019 21:44:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554698663; cv=none;
        d=google.com; s=arc-20160816;
        b=VBifTVVfveEmopmBBQQOYRBb8qZQ+KhJrRpWI8qSfYOurylXiuT0CHYYMD7BwY5g8Y
         7c8HFBmBLOCVlxgtl1k6CqMeIXgCV+b9EXy1wtL4QNXPhHeyVCpv2aXZl+aoKT4vGOFp
         Akn1IxnF1yIIZjJDzdGj1iquq5N3psUF4p/DhwmoRAX+eV7ApmrL1QVCjIqD/tWKxlL5
         mPH2+JVYCNnlPF17bFd0QgCO3nbi3EAGNTOW4Wf2hVxlWLjRXZrvZTIJm1S5epwkLLrb
         rnLGa+jkFC6SiA3NK7qImLm+U4IIk14W8pQ2AhDOUNvtG0gBelo47hWyeFV0nxIMUP/S
         Tl8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=0pfBnB60nfaq0Lris59bgawiBT3Gg1IQEoag+3VPJ9A=;
        b=OnVakgYccwQUE3X7gXSfi2teK5utS9pqIPVcp2ElB4AWL4CjTEdX2238S7AavdBm6/
         +kna3GdaG05OtsQ2boQMx1nbvbnZf9x8zPwqtOUP/kkckH6DN83m3muWJTvhnE6wsnoo
         864MQiNZLOZPnOKQuaWNnJOxbQenKgXitibBZsDQEzJodD5zMwDBdSOK/3CX1W2FRYiC
         QGPsqUkdfuFZhYMeg/bAJJS2ktRlFU4xCnimCqEPPMB9mg6S5aUppLSlF1MampnVtMdP
         voJGrNIPzv3LMCy9eySlmnURBktNIIK4mk79uJl8Ll7BOZ43muOP+z6fAz6uoK/+54a0
         meTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gnGCe3xj;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e22si24286196pgv.323.2019.04.07.21.44.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 21:44:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gnGCe3xj;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=0pfBnB60nfaq0Lris59bgawiBT3Gg1IQEoag+3VPJ9A=; b=gnGCe3xjoHoh34UQiWRArnDC/
	gCin2I2YIjvw53ApSM20j5U+CLCEYAAJTyfLO3Ns63RDLMpOQ4EIqWO9arQBWMCYXV9CEZGjonh/i
	HxkugAB5Yf38U+XfhZygPC28Cyw7zUiLx/RCmhRpZjHsEIiWc7kuJFzXGlUt3YrRQLm17UEhYT1/I
	deLJ6YUjh6hMTlBKpYdntjn/FtQgLAIi0ZkYPEeR2gdJWReuDNVrGBdL8bsW0uhPTSyqmcEIpLjgO
	Wuh6KwbrfcVdeSv5tIYcodxMfKeqNpogs9j3cDk+MTR2KE6ihtNHfzfompCAIWbNkeaABH9ekVTtK
	QGjOWY+xA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hDM8q-00018R-5f; Mon, 08 Apr 2019 04:44:20 +0000
Subject: Re: [mmotm:master 227/248] lima_gem.c:undefined reference to
 `vmf_insert_mixed'
To: Qiang Yu <yuq825@gmail.com>
Cc: kbuild test robot <lkp@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org,
 Linux Memory Management List <linux-mm@kvack.org>,
 Manfred Spraul <manfred@colorfullife.com>,
 Johannes Weiner <hannes@cmpxchg.org>, lima@lists.freedesktop.org,
 dri-devel <dri-devel@lists.freedesktop.org>
References: <201904061457.ZCY5n0Jo%lkp@intel.com>
 <c71215b3-8a6a-a4dd-b9bd-9252bd052a32@infradead.org>
 <CAKGbVbsFXvEjxNH7Wm5Qr8ODyDfJ438qRELn0AB1BJdVV1AK6Q@mail.gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <162043bc-a3c6-f5d6-f073-c52b1c5ec8b9@infradead.org>
Date: Sun, 7 Apr 2019 21:44:18 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CAKGbVbsFXvEjxNH7Wm5Qr8ODyDfJ438qRELn0AB1BJdVV1AK6Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/7/19 6:30 PM, Qiang Yu wrote:
> Thanks Randy, I can add these.
> 
> Where should I send/submit the patch to in this case? Still drm-misc?

Sounds good to me.

Thanks.

> Regards,
> Qiang
> 
> 
> On Mon, Apr 8, 2019 at 3:08 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>>
>> On 4/5/19 11:47 PM, kbuild test robot wrote:
>>> Hi Andrew,
>>>
>>> It's probably a bug fix that unveils the link errors.
>>>
>>> tree:   git://git.cmpxchg.org/linux-mmotm.git master
>>> head:   b09c000f671826e6f073a7f89b266e4ac998952b
>>> commit: 39a08f353e1f30f7ba2e8b751a9034010a99666c [227/248] linux-next-git-rejects
>>> config: sh-allyesconfig (attached as .config)
>>> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
>>> reproduce:
>>>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>>         chmod +x ~/bin/make.cross
>>>         git checkout 39a08f353e1f30f7ba2e8b751a9034010a99666c
>>>         # save the attached .config to linux build tree
>>>         GCC_VERSION=7.2.0 make.cross ARCH=sh
>>>
>>> All errors (new ones prefixed by >>):
>>>
>>>    arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
>>>    drivers/gpu/drm/lima/lima_gem.o: In function `lima_gem_fault':
>>>>> lima_gem.c:(.text+0x6c): undefined reference to `vmf_insert_mixed'
>>
>>
>> vmf_insert_mixed() is only built for MMU configs, and the attached config
>> does not set/enable MMU.
>> Maybe this driver should depend on MMU, like several other drm drivers do.
>>
>>
>> Also, lima_gem.c needs this line to be added to it:
>>
>> --- mmotm-2019-0405-1828.orig/drivers/gpu/drm/lima/lima_gem.c
>> +++ mmotm-2019-0405-1828/drivers/gpu/drm/lima/lima_gem.c
>> @@ -1,6 +1,7 @@
>>  // SPDX-License-Identifier: GPL-2.0 OR MIT
>>  /* Copyright 2017-2019 Qiang Yu <yuq825@gmail.com> */
>>
>> +#include <linux/mm.h>
>>  #include <linux/sync_file.h>
>>  #include <linux/pfn_t.h>
>>
>>
>>
>> --
>> ~Randy
> 


-- 
~Randy

