Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD063C10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:49:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6372B218D9
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:49:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6372B218D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ED058E0002; Fri, 15 Feb 2019 13:49:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09D628E0001; Fri, 15 Feb 2019 13:49:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECE028E0002; Fri, 15 Feb 2019 13:49:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABA928E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:49:10 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id y2so7455195plr.8
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:49:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8BqfUTrmG9AUbgAfUDyLWEJtZhE3sV0I/04jd5RhNTQ=;
        b=TufwQYvcF6bX5X2w6Z5gqJE90nPSOFm6HgC/Ra6TpqMrYaLTsGAZ+ttYV1XzLHGgi9
         lM2Frz2Nfs3YXYhrdq6b4zjGaEHKSw24xMOXWc6rqQ3/r4L3J2FlPxT9ODufbNIdTehp
         GJ6zcBNtgJxbIU0CAi+32HM214yflUVmkCgFtH2MCKSYzQDFahWpWc3P/1n2A9zbCsev
         LSjnParRrTh49yFMzX477v/4t/HCdzsb/OSKc46lIjygJbI2Ia2OudbY8cD2375nQSBU
         FyPHSzYyBwOcFW24hI09NAKsKzb26JseSRFgexxTRmEO41wAk9tsWP3kxWzHCnQGoR4r
         oECg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuYc0JtCUn9AbLLQIHeJ3iHkD2FjmfHnQ26ddzyoc4WW8oIgFK35
	EZWD3Ew+ZiHmzO5yEdzYqob2nax/ga2bdwIFiw9O/u1qvSwbwlrViXBjceXAaXGqPqxd6LNx40k
	l4GJv9IUGJHOZA7+iqZ6dWeaQd8zQ+uM7zfXDgiSXOnwpnCkoO/51KJt0D7o21Q3BYg==
X-Received: by 2002:a62:53c5:: with SMTP id h188mr11037366pfb.190.1550256550345;
        Fri, 15 Feb 2019 10:49:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IajWxcRJkTiKtiS4EnZsE+aYiXVgSmrCngT3uY6QzwUD/8xdQG8L/vcJN042XnSzcPBrcZL
X-Received: by 2002:a62:53c5:: with SMTP id h188mr11037286pfb.190.1550256549339;
        Fri, 15 Feb 2019 10:49:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550256549; cv=none;
        d=google.com; s=arc-20160816;
        b=pxlNexMqv4Cs+nGl1DjmeP4WlL3931VFRAEOGzHqEEhgUh8SGE49jLNafrataPzarf
         LS7uuaqK/3Cb3ezvAE7/bRfG4B6a0DGiwyNWItOMke74If2Wcqd9t2sORiOY7o3Zmaun
         k4doIC5rjGYk7YRDOLKRh8FLBEARz1lR5Ep6+LL3INj4DKM3tQ670t6SGvejdX9GDQGm
         kLFaVjtYp1CfSo7hBfaRd+q6RpNOIz6eR7xpsdTv6pbdXJ2KROdm0VsbGtDySUuu/zBB
         Vs6NybejVsbAzmCw3hx3hrdCug3t+wjm6o2eHtwKUCRvREeXnsRRnqGxjLFlIOSANm8P
         cZJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=8BqfUTrmG9AUbgAfUDyLWEJtZhE3sV0I/04jd5RhNTQ=;
        b=F3ZBQsxLZqqjHGqOCmS+BzHzIqibYBwcKsLZRszCgjbPy+PRBonzAZSLn0axRDVIHn
         BSS6p8yWSDIXUB4yxWgskbbvuJls7rDta48qOoEIJrS2CfSkBHwGQzAZieydXEpUlSBo
         5vfs68W90qkxopptegka0G5NPsl2qofAmPoy2bWbKpu0FKNT6eNtrcCttsZ8LwLuMtQZ
         O3107bGFOykA2ycxlwQiFMEt2XQ7vU52k0+qn41K+/uG19oedFQJrsn3yIf5rjHcQOEU
         V5ugmp1mQTrmiaQccDyDHR22xH/gvo1wFyXrBfqG2csAmUNUIZ6D5eNIR3CnWneodY2V
         myKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x64si6273898pfx.87.2019.02.15.10.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 10:49:09 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 1EF3AC2C;
	Fri, 15 Feb 2019 18:49:08 +0000 (UTC)
Date: Fri, 15 Feb 2019 10:49:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, kbuild-all@01.org, Guo Ren
 <ren_guo@c-sky.com>, Juergen Gross <jgross@suse.com>, Geert Uytterhoeven
 <geert@linux-m68k.org>, Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 8266/8290]
 arch/xtensa/mm/kasan_init.c:49:35: warning: format '%zu' expects argument
 of type 'size_t', but argument 3 has type 'long unsigned int'
Message-Id: <20190215104907.9ec4f0a5277703ce05d278a4@linux-foundation.org>
In-Reply-To: <201902150710.iERneFPC%fengguang.wu@intel.com>
References: <201902150710.iERneFPC%fengguang.wu@intel.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2019 07:26:21 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   c4f3ef3eb53fd7e8cbfe200d5ff6dba2b08526b5
> commit: 5107c1e0490f01323cf3296f758271b06d9bb0f9 [8266/8290] treewide: add checks for the return value of memblock_alloc*()
> config: xtensa-allyesconfig (attached as .config)
> compiler: xtensa-linux-gcc (GCC) 8.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 5107c1e0490f01323cf3296f758271b06d9bb0f9
>         # save the attached .config to linux build tree
>         GCC_VERSION=8.2.0 make.cross ARCH=xtensa 
> 
> All warnings (new ones prefixed by >>):
> 
>    arch/xtensa/mm/kasan_init.c: In function 'populate':
> >> arch/xtensa/mm/kasan_init.c:49:35: warning: format '%zu' expects argument of type 'size_t', but argument 3 has type 'long unsigned int' [-Wformat=]
>       panic("%s: Failed to allocate %zu bytes align=0x%lx\n",
>                                     ~~^
>                                     %lu
>             __func__, n_pages * sizeof(pte_t), PAGE_SIZE);
>                       ~~~~~~~~~~~~~~~~~~~~~~~

OK, thanks.  UL * size_t = UL.

--- a/arch/xtensa/mm/kasan_init.c~treewide-add-checks-for-the-return-value-of-memblock_alloc-fix-3-fix
+++ a/arch/xtensa/mm/kasan_init.c
@@ -46,7 +46,7 @@ static void __init populate(void *start,
 	pte_t *pte = memblock_alloc(n_pages * sizeof(pte_t), PAGE_SIZE);
 
 	if (!pte)
-		panic("%s: Failed to allocate %zu bytes align=0x%lx\n",
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
 		      __func__, n_pages * sizeof(pte_t), PAGE_SIZE);
 
 	pr_debug("%s: %p - %p\n", __func__, start, end);
_

