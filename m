Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC838C31E5C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 02:07:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABB2D20833
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 02:07:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="FajhClF1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABB2D20833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25A536B0005; Mon, 17 Jun 2019 22:07:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20B268E0003; Mon, 17 Jun 2019 22:07:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FB378E0001; Mon, 17 Jun 2019 22:07:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CACC06B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 22:07:36 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id b10so8877742pgb.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 19:07:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EZ2UuCg8w8nHpDLiMKk2txunEBzJtJXgiX9mP0J0+jE=;
        b=QDlJUh7fwSb3rBSJDR9PCygv9D6as4gZtNxwMt4/LB7A6FbGGh8iw6kBov/mqvlMSv
         tl+D+aD5wyzrv52E3gIkJ+uM8zz0lIQMonGzzwE9YbBj5YCbugY3XpmVQZELTHRqyeEC
         uSRUr7BSNxJpxRpzfPi9WO4wEPh8usDHE4r3mJVde87k4dztvwE2kFqtkxh+RCugqJmS
         Ocl76XCv8S3XUnv0S68UuMpe7TUrwDxQkBCiGGttkjPqPMRSfO7i0RoVelMjJ+Tb2/9e
         3fapPGy7mSBBSir/u/V9xg65UXwKtz4CH0INFRTS5tUYztODYdVG+8RPWIr8H3bqlSSd
         KVZw==
X-Gm-Message-State: APjAAAXHf0zGzBm4hz18JHqc641IaJLPNzuOdgVpZdfrG2Lw7wxonvkn
	TRFxHwVNH9jb0pIuqYFQ1sYPmNBZ821vPCsa/6/R9ZS+efOwZLYz2rPJkbn6vcFr9f2bVK4IZMm
	ZATgVyCKC6wyAkHtwfWuVPhKPxL1kSMx+NDhJacloS7KEpwdFNfVerS+f/QIjvybTiA==
X-Received: by 2002:a17:90a:2743:: with SMTP id o61mr2384969pje.59.1560823656460;
        Mon, 17 Jun 2019 19:07:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzh+JnVpJOC6y4khOlcWIvhNDZ6DXd4PRZHlmeyNH0sHRuha+KqLvePtO132BvNQxrQhwjW
X-Received: by 2002:a17:90a:2743:: with SMTP id o61mr2384936pje.59.1560823655743;
        Mon, 17 Jun 2019 19:07:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560823655; cv=none;
        d=google.com; s=arc-20160816;
        b=CDaoC2XN4hm3wiVITQwwwVFrfu114SZ5NG2fgO2K0+XpB/HpKs+L2bZ034WvDoAWN1
         UZKQvsHNKXOPZ974qMpBA8dJ9VyJTF2Uj45xY41IctVfrZK1MOVEk3kmuV6KF1z2GkYf
         gaRSw+ogX2BvMpQnl2UDVaqG5OUOL08BGCaO1GWGK9++TJ1Iat5nKYCdoxe1YPOhKw92
         Yuq1dGF1aNWMFWz4wmmREuDu7gyVVF/MZNniXNPlFxPi7/hUBKje8Q6s4L1W6kQJKohT
         BK6vVZA/4a1qDv/fjMeyGz7vINMZJppNrWpdAqTEUA7jLrSqmxqz8TKeRI4ibxizauwy
         b/vA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EZ2UuCg8w8nHpDLiMKk2txunEBzJtJXgiX9mP0J0+jE=;
        b=X4zdlztEcrUT0gvNwOMx3bsaUYZlUNzSbnB0IwnT2AJHWFbps+Z2bTeumMDjJz6qHY
         H0qH7rlVOtyTbWFaWyA5ZRM4L02IBXc0sA1nV6kFSvk/ntWYiNJLjqVHOwelbyCTqVDv
         gs/K5ubN997rX91vkQP0kuowjHeZGd6MmwpC4BxB+iKc4Gai5VvJsDmE4g3LVw0LvVKj
         cFNKS22TYLivziSA4axZ/QRFNmt5oBUAN+5a43Gm4Y94sBojlV8b2P/rczNzLOMhDfIY
         rEBc4giLmuwzQEVOo8IjbAkNhFUMb5Q0wzvJ4Os+/v6BAZq3OTPBjHIEcrFzknRj/pL6
         FKHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=FajhClF1;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s3si820067pji.94.2019.06.17.19.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 19:07:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=FajhClF1;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2530A20679;
	Tue, 18 Jun 2019 02:07:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560823655;
	bh=WqjIcvKMXP1KCJe+QkI+brxsQg9uSj0RigwQeGFrrfk=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=FajhClF1QwzHRY30DQoHsfpeWT+GoajGldJDUyCm29arVoqpGCFUhQVGevVPWOu61
	 GpwHzcR8yMz7MitCRozsVkrGqScElTawEWXoPrDGOvusZ6rKjS5Z7qOcunpnStIvTG
	 AuNRkTZ94mXsMxzTmu8MB3IXLKsLM3y3QEAJkm1Q=
Date: Mon, 17 Jun 2019 19:07:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, kbuild-all@01.org, Dave
 Hansen <dave.hansen@linux.intel.com>, Linux Memory Management List
 <linux-mm@kvack.org>
Subject: Re: [linux-next:master 6470/6646] include/linux/kprobes.h:477:9:
 error: implicit declaration of function 'kprobe_fault_handler'; did you
 mean 'kprobe_page_fault'?
Message-Id: <20190617190734.e044c1ba48d69a3cb3e01f59@linux-foundation.org>
In-Reply-To: <201906151005.MbWIPMeb%lkp@intel.com>
References: <201906151005.MbWIPMeb%lkp@intel.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 15 Jun 2019 10:55:07 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   f4788d37bc84e27ac9370be252afb451bf6ef718
> commit: 4dd635bce90e8b6ed31c08cd654deca29f4d9d66 [6470/6646] mm, kprobes: generalize and rename notify_page_fault() as kprobe_page_fault()
> config: mips-allmodconfig (attached as .config)
> compiler: mips-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 4dd635bce90e8b6ed31c08cd654deca29f4d9d66
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=mips 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from net//sctp/offload.c:11:0:
>    include/linux/kprobes.h: In function 'kprobe_page_fault':
> >> include/linux/kprobes.h:477:9: error: implicit declaration of function 'kprobe_fault_handler'; did you mean 'kprobe_page_fault'? [-Werror=implicit-function-declaration]
>      return kprobe_fault_handler(regs, trap);

Urgh, OK, thanks.

kprobe_fault_handler() is only ever defined and referenced in arch code
and generic code has no right to be assuming that the architecture
actually provides it.  And so it is with mips (at least).

The !CONFIG_KPROBES stub version of kprobe_fault_handler() should not
have been placed in include/linux/kprobes.h!  Each arch should have
defined its own, if that proved necessary.

Oh well, ho hum.  Hopefully Anshuman will be able to come up with a fix
for mips and any similarly-affected architectures.

Also, please very carefully check that this patchset is correct for all
architectures!  kprobe_fault_handler() could conceivably do different
things on different architectures.

