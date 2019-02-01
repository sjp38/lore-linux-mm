Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6EEEC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 21:47:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABEF320863
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 21:47:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABEF320863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EE3B8E0002; Fri,  1 Feb 2019 16:47:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 374F18E0001; Fri,  1 Feb 2019 16:47:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 217AB8E0002; Fri,  1 Feb 2019 16:47:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC0748E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 16:47:40 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so5658733pgq.9
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 13:47:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CnZzrkFcbtXa7opbj3d92bqznUY44Kobqa47vX9wd4A=;
        b=hlKVGpZxqWbuJ6two7m1b+Ia4FqjHlCI3+kVMGHC+1zdFKDMNmoLfz7E+bhk/YUeNO
         xiZ1iKpMSRwzTia8BowrhWf5M+SX4z3SEX/z0XJzIT00EeTYVfFVACngZONknMdSoZk+
         Gn8dtteJQXTpySa1QPMXs38cyHwrg0eGXtd1hZ1aGApzrIOhSIbEGc84fYUkW1bAguIx
         3IeSveLRdHvEUT4g4fSEBCkymUCKlyGEPWPtzVzjJmSCCRX5Vh9scz35FI4VZRgcc9Pe
         gEPl2sNADKlPFGLcce8/2Uri7cSJRhprlOHbhcNQqytWeps3bYaDClePdSFQs3h7FAA1
         dAPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukdrqumSEwex5hYmJJVm1CY8A822eTrMnwlpiUDueT4kzhfED2G7
	qpmSYKe1mxrFNlaZnKI1biYzAYyP68l7FdD2UtUBmFM09+IazUMhWpm/PkN8c6DlIzX3daWNQAI
	5K6WwbpfMKC0LvxrVUC43rPbuD61gczEzPVFiRrMhBqPsjr54fqtG+wJBWICL3eypxg==
X-Received: by 2002:a17:902:bd86:: with SMTP id q6mr40070045pls.16.1549057660430;
        Fri, 01 Feb 2019 13:47:40 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7pBUqfk2+DdjK9snbw5eYgQtSN/hWWc1ov43KYszgn5sNMYVMdcUmk2NmXIxtN+LZgCIqw
X-Received: by 2002:a17:902:bd86:: with SMTP id q6mr40069995pls.16.1549057659386;
        Fri, 01 Feb 2019 13:47:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549057659; cv=none;
        d=google.com; s=arc-20160816;
        b=lLfRWnnv21+OLaqjUTEqJw//eBaJtxmcNu/3r413f2cA6VV8yu+c3XcMjtcFcxRS+T
         buQBRQXW+1WXxYsJNuLTKqeek8z4zvw13U2fsveKu50D8OHzRFziE+jXtkRIxwcqLWIn
         uQf7dFrhXTvHU4XcXiflLRj2B0q9tQ74e/sSovaciPeeAihwoYbB7mIb3O/Hod0b9/k9
         mqtzTFvHRykWLeSwnwTh9ETPHRxcKLPrhtuxWzr+VAiVAdPGWl5YQrdKqPgoUXvMdKA4
         GJ6KKsUjH7WqQPM2njIwpn561F/aGWXXgDUkYAmAaGlSWdjQmir3VzqojDc8z0TsEpjt
         pgWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=CnZzrkFcbtXa7opbj3d92bqznUY44Kobqa47vX9wd4A=;
        b=ptb+ZLxSmpqT4Rz0wbeJVfdFIkhrJ0X+PQk+U3vbwhmGtAlPE3jvmotpjQFMDkqgmz
         qJ+9IFxXD5iRiFdjun2Ani3sH75NtJ+bRdPl+Q7DPRqheVVnRQO4s/Dx/ttE7Apvx2V+
         Ohv4WhT4X2f6R8sxcWw7VZWTyt+Z8POnSdFR1VfQb9/NJfMO5Qn0NAYvxE0rB9yE9QPx
         AjGTyGW/Fyg91fPvxsbpfgLW6KM9Oq1ilDupxO0HtIJLr/UYY9n3nlDnu0ngzId1oxGS
         gbmwMf1ZiodzLH2b0h5riHC93uMiKXKRGFBmOB+hAHMzlwDcnSH2ZfQQPK/Sx/4LbSsk
         34rA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g124si706645pgc.568.2019.02.01.13.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 13:47:39 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id BBBF77FD0;
	Fri,  1 Feb 2019 21:47:38 +0000 (UTC)
Date: Fri, 1 Feb 2019 13:47:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>,
 kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 5141/5361] include/linux/hmm.h:102:22:
 error: field 'mmu_notifier' has incomplete type
Message-Id: <20190201134737.9eaf0c69dc2584d2dc4ec4cc@linux-foundation.org>
In-Reply-To: <201902020011.aV3IBiMH%fengguang.wu@intel.com>
References: <201902020011.aV3IBiMH%fengguang.wu@intel.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2 Feb 2019 00:14:13 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   9fe36dd579c794ae5f1c236293c55fb6847e9654
> commit: a3402cb621c1b3908600d3f364e991a6c5a8c06e [5141/5361] mm/hmm: improve driver API to work and wait over a range
> config: x86_64-randconfig-b0-02012138 (attached as .config)
> compiler: gcc-8 (Debian 8.2.0-14) 8.2.0
> reproduce:
>         git checkout a3402cb621c1b3908600d3f364e991a6c5a8c06e
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from kernel/memremap.c:14:
> >> include/linux/hmm.h:102:22: error: field 'mmu_notifier' has incomplete type
>      struct mmu_notifier mmu_notifier;

I can't reproduce this with that .config.

hmm.h includes mmu_notifier.h so I can't eyeball why this would happen.

