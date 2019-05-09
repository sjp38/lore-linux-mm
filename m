Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,T_DKIMWL_WL_HIGH
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBFC7C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 23:11:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B5B1217F9
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 23:11:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AgZ9nGki"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B5B1217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AD376B0003; Thu,  9 May 2019 19:11:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35EB76B0006; Thu,  9 May 2019 19:11:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24CDE6B0007; Thu,  9 May 2019 19:11:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E36746B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 19:11:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 17so2638467pfi.12
        for <linux-mm@kvack.org>; Thu, 09 May 2019 16:11:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=otF13VeCQdd7dt8OGygLpuUngOsWT6BUaEZ4Q2r79A4=;
        b=RXWNaX7YKrnjh5Q6krR910aT8WLBT35I+g0IHW9w25y43A4wArw6D6/K/ZNvWchIu0
         pIkzHsKQn9bj5VtmAngyUjl3IM6podFmuXSY0l66pMvoGhS3tIXyZaPy9+g7xS7Qmhjm
         6/xIJ1N6ImsnUyYukGhZp0/l50ex1iWLgQppEqDW6rzEuAiuql/rY4kKmWP6Ael9qB6m
         dmdmSU63qHWgAjaSBuvxcUUVzRHAtgYvmL0nSdNSUL6xTs3O+QzgXmd/mEhavJziptIk
         vmlHd+9mOwmy81Mzepu2KaImswDDhcsaIOxbaCJuKbVeSjArYIikUk2vy/z+m6NfunrI
         IvSg==
X-Gm-Message-State: APjAAAX4k8H0mTl2YAnOc4peFAFRiC3aUeCuLcd1R08xWcacwexTC2ss
	/ChECTev0jPQf+WqfKQ/p7mY2UtkTRCEByGy89ILygo0ei3fASLYACnkWJcs0KnQYKAGjFrgcja
	VRy9xbEwxhdMhDeQc2RRxZybUC6ih8T+IpSDjYk+gCiVhdE51hnaJPKWmOTy74hxvug==
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr9048445plb.202.1557443498026;
        Thu, 09 May 2019 16:11:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxL40f/rYNEqFgUIEzj4aBCiLH/VGMIYKSEXwJscazC9KlDodYqicbdOqZ5V0u4jK7q+Uzg
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr9048378plb.202.1557443497261;
        Thu, 09 May 2019 16:11:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557443497; cv=none;
        d=google.com; s=arc-20160816;
        b=B9MenAenBjuBH04VaEefjS7VrsVOOgAdq2ZtoWKgsptN/4OeP9dbuyhyt4y5XODs7E
         wbGCAhZKXAMuPqTP5g9Dhdjwv3vofjz2guzoN/so19AUoMa3lzdxFLZitsmSD+laS9q/
         NE4K62fZWgpoZy8KdfYQA7tbKHNCRXL98B5kQzdVHERMBqpBmy3U+/YzHyWo0UrEjmhB
         CxZoN29gZ5PvLPK47Uoy05b+/mDRkM3+1Bf2jM0MvCIXVY7dHocjSNx0EigDms7uTWKP
         YRb/X1Rnz81WY2UghKVwQcEWfpI30t6lo4U41tezviO7tmfnYUd1ycilxsr5/CenpUUx
         446A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=otF13VeCQdd7dt8OGygLpuUngOsWT6BUaEZ4Q2r79A4=;
        b=WTgTfvuwylRfAk/IXN+3Zt2taHC3qzT7seUlL6BMhHmgUR36mnVfMEySygw5M/+8MS
         lAeHODiSCrdLrNL1aqconBqZBR9e6nUPrLkZwmzgxjjfZd25rCnGk9WTJ/28bItuQDzr
         q02yzwwUSPQfsDmY78wz4TxH1updc6ZM8Muh1gLg8VEkVc1R6wzl50jUBTLM5drRlZNK
         2Ilt3Mrfi0IWxp5wa1ppUeSMSBRINXvR3YjJJI+dgbcvimkwsFbI9hFCqK/w2NP2A3O8
         xpGohgEc9QN3BbAy08msBKAJCYc5B2vgjYZUDSAeofz+xCX35u/xblaNcOztmMRnKRYS
         RoPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AgZ9nGki;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e26si4575514pfi.54.2019.05.09.16.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 16:11:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AgZ9nGki;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 50F642173C;
	Thu,  9 May 2019 23:11:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557443496;
	bh=4czGVVwxwttY99MriEH8D5p/ohHXnX9UEsQ9++fXAiw=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=AgZ9nGkinsJeJnmcfS5Jgm3wtmVHuRU5lptN1SIUZM/xc4SVbVTukk0uVJmEYFG63
	 fMg9LLzPL0e+JcHsSReAaSejpacJiUpDr0BieQ4pJA82YRn7b8Ey8V+LYXI+wAGnu0
	 Lk1B0ytS5mLdcAT5Yjxpl6AjFwv9CECO4jFRec8Y=
Date: Thu, 9 May 2019 16:11:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: yuyufen <yuyufen@huawei.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Naoya
 Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A . Shutemov"
 <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org
Subject: Re: [PATCH] hugetlbfs: always use address space in inode for
 resv_map pointer
Message-Id: <20190509161135.00b542e5b4d0996b5089ea02@linux-foundation.org>
In-Reply-To: <5d7dc0d5-7cd3-eb95-a1e7-9c68fe393647@oracle.com>
References: <20190416065058.GB11561@dhcp22.suse.cz>
	<20190419204435.16984-1-mike.kravetz@oracle.com>
	<fafe9985-7db1-b65c-523d-875ab4b3b3b8@huawei.com>
	<5d7dc0d5-7cd3-eb95-a1e7-9c68fe393647@oracle.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 May 2019 13:16:09 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> > I think it is better to add fixes label, like:
> > Fixes: 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
> > 
> > Since the commit 58b6e5e8f1a has been merged to stable, this patch also be needed.
> > https://www.spinics.net/lists/stable/msg298740.html
> 
> It must have been the AI that decided 58b6e5e8f1a needed to go to stable.

grr.

> Even though this technically does not fix 58b6e5e8f1a, I'm OK with adding
> the Fixes: to force this to go to the same stable trees.

Why are we bothering with any of this, given that

: Luckily, private_data is NULL for address spaces in all such cases
: today but, there is no guarantee this will continue.

?

Even though 58b6e5e8f1ad was inappropriately backported, the above
still holds, so what problem does a backport of "hugetlbfs: always use
address space in inode for resv_map pointer" actually solve?

And yes, some review of this would be nice

