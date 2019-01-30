Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C89FAC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:13:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 450CD2184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:13:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 450CD2184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9ABDC8E0002; Wed, 30 Jan 2019 17:13:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9331F8E0001; Wed, 30 Jan 2019 17:13:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D5AD8E0002; Wed, 30 Jan 2019 17:13:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF5E8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 17:13:40 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t10so745127plo.13
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:13:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XjEpvfaIkyd6BW3IsVNSwAgcZVmNR0pbtnILyZ39ht0=;
        b=tqPhrv7vB42Tf3R7iUyq/j8niRYRgRq3h1BQdzbb3We6eT3eQ40MGNyD2ZUFWQBqDD
         KtH8ToQ6FXWPJrDA76JHGLUUPnQ0lJBlVZi6D76L8ug6GMWf54MxGk/1slZG7nojX1yC
         36Fwa+eXlnj8jyGS8zyg2KN0/eL7tDwOVDM1ZRD0ksM+PXPS+k4kNfjAXrUkOKJ685/Z
         QR7MHoqyQwhAHjBZPgsRjptQGDxRi4LCwS9cV4mb61mDvLmWHQzhS6aa6V9bVCgZ+Pab
         2WdKTyHeEMCFekzqum2eKH/Lbdcz36mwLPe6guXEacRLhRKWMklMqSdenzpdf16+goOX
         8v9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukdzA9droitG6BdzyG0YKZX4DBxHF2Zk7samLZmMGSmD+8hr7RTv
	bO1ukU4cGt9tWMHcGGwfS83Fl3CkInNuVqk7qWZ/TWS65mM6pNicZH07fgDjk+OhDqyc4eQpYf6
	b0oRYOB7pgG3lSmTXvbfDAMGahKxBXrcS43hg5fHzjblcIHaCAz2/MVSmdSsQTl5TsA==
X-Received: by 2002:a62:33c1:: with SMTP id z184mr32056295pfz.104.1548886419840;
        Wed, 30 Jan 2019 14:13:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7vtwY8vhJbq0EllSi9HGNwioEPy6WbGE6eO3LhUBCRpV4a7/jitHnQMp53nRvNz60d7ONC
X-Received: by 2002:a62:33c1:: with SMTP id z184mr32056257pfz.104.1548886419130;
        Wed, 30 Jan 2019 14:13:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548886419; cv=none;
        d=google.com; s=arc-20160816;
        b=Bgz9RoTJossL4/9e+TrUU2TKh0q9FLmum5Jvbk5yQ9YvJbGjTWl/Kjpv7r0ZAYoTGk
         MRRMjAL3x9+nanC1f/oe9tzTaHMMDUGKVbUxyTdhc2bIubVoLqd9lRWHcv0v7Fcncsy8
         D3UY8r4P3Ul22IkpAj/+sPgFZh7O0HQOMm+ZGhYB37SQv3peamtu7K9FH5nYXZfuCurz
         BB2tlhU0jsA8f2JDoIDj3Di3V+ICLOZ/TevPha2iFlQXbPZe1IT5/sYlUhMk5oSbbGEb
         zjdmgafE+eSbCdl7hW1WrA/iMIT+UlNFjBxRl2NNcKu/+UgaViT0AAviMFzR/1G7BMxY
         AbvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=XjEpvfaIkyd6BW3IsVNSwAgcZVmNR0pbtnILyZ39ht0=;
        b=1AQ6YvmDdyiwBxdxSvRNZWPCmE/8/9akyAB7fEoh9+IpmefVEH4jOKD6ceepZFXafm
         imy0AmDjOtPDYuUX/2YL9DS6f5vCOEVH2fGz+lnVvle0w/UMiaogynp57xVpMBNv4F2d
         1XiQpLdA0cuE2/Q/+3si7q3wonlli869WpKfw3Kjw4VDT0lBIS1BzT3uUvonZhHMxhlI
         i3IcBZYRPLr+GInKSdcmj/7SkxjwADEQI9HvrVnTwUwybStoHCO3Jfq/uQdguDD/RXfO
         O01PBDYnwdupn9C9vfgF69i7oWAup/O7dBqLuohqSxe0KqR/cd9wXXLRhL7h0GR/L3wY
         ASTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d34si2494010pgb.43.2019.01.30.14.13.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 14:13:39 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 3E66B3CA4;
	Wed, 30 Jan 2019 22:13:38 +0000 (UTC)
Date: Wed, 30 Jan 2019 14:13:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Yang Shi
 <shy828301@gmail.com>, Jiufei Xue <jiufei.xue@linux.alibaba.com>, Linux MM
 <linux-mm@kvack.org>, joseph.qi@linux.alibaba.com
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
Message-Id: <20190130141337.5d0d5e96e5544bf562cb5b8d@linux-foundation.org>
In-Reply-To: <CAHk-=wjEHQZyen7WEG5K5gC_5gEb9gM_r+WtpkfsLkYFstN5XA@mail.gmail.com>
References: <CAHk-=widebSUzbugcLS2txfucxDNOGWFbWBWVseAmxrdypDBrg@mail.gmail.com>
	<CAHk-=wg=gquY8DT6s1Qb46HkJn=hV2uHeX-dafdb8T4iZAmhdw@mail.gmail.com>
	<201901300254.x0U2sKdE090905@www262.sakura.ne.jp>
	<CAHk-=wjEHQZyen7WEG5K5gC_5gEb9gM_r+WtpkfsLkYFstN5XA@mail.gmail.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2019 09:18:20 -0800 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Tue, Jan 29, 2019 at 6:54 PM Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >
> > Then, do we automatically defer vfree() to mm_percpu_wq context?
> 
> We might do that, and say "if you call vfree with interrupts disabled,
> it gets deferred".
> 
> That said, the deferred case should generally not be a common case
> either. It has real issues, one of which is simply that particularly
> on 32-bit architectures we can run out of vmalloc space even normally,
> and if there are loads that do a lot of allocation and then deferred
> frees, that problem could become really bad.
> 
> So I'd almost be happier having a warning if we end up doing the TLB
> flush and defer. At least to find *what* people do.
> 
> And I do wonder if we should just always warn, and have that
> "might_sleep()", and simply say "if you do vfree from interrupts or
> with interrupts disabled, you really should be aware of these kinds of
> issues, and you really should *show* that you are aware by using
> vfree_atomic()".
> 

Agree.  if (irqs_disabled()) {warn_once; punt_to_workqueue} is the way
to go here.  vfree() should be callable from spinlocked code and
might_sleep() is an inappropriate check.

