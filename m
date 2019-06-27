Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1FFAC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:18:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94AAF2086D
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:18:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94AAF2086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 301C58E000D; Thu, 27 Jun 2019 09:18:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B2778E0002; Thu, 27 Jun 2019 09:18:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C8888E000D; Thu, 27 Jun 2019 09:18:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4B598E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:18:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d13so6030620edo.5
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:18:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=70z2rcphAVlN3RCxXpjlhCAT2xxc48XcyKG/wAa7qjQ=;
        b=BM7JRDJGShAZ2savQ5N3P221rmGLwnvnj/7X58kU04rSKzqOpRxeLS9XweV2oGHsQO
         pO6Xo7G/Y4HQADR9R/VR3anaxXZVMUlTbbOmM/FiatfNo781aIANyKUsD8mXzbK+9mhy
         3p+he/8w0h7HPK8b8Kz5N9pFt+ArB5A56JKUmKxNdxindieCuh/Yy/KCdSMdBUBhcW+w
         lFfo8YeULyLkV9IBR52parjx0mjCukQzRLt2tahCltqqcHKUTj0FqpX92KklXqV0h668
         NprwW9x/Cojh238C4LdJuTjPK5PoxvNjGZXr8ErKgu7pZTWydshulzVk/jUT6o09OAjF
         xcIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of andrew.murray@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=andrew.murray@arm.com
X-Gm-Message-State: APjAAAWkhW4O0PrYUSDuWSgmMb4KdSF/xlGnzkVkj9Wjd+lrufkI9U1O
	nc42/SFBMf1LYdRuDYP/i40/8kDWhKPChKskXYQQNLYk0RsrrJFMtrH3V41RUKImBcmydqS0V+t
	8FTdoCOlWBntNjk2FW0xwF0f1RGtdN0v+t49WMVfxKKRQNKRws1xYQLwOGnOBcIfvhQ==
X-Received: by 2002:a17:906:45ce:: with SMTP id z14mr3183732ejq.144.1561641519197;
        Thu, 27 Jun 2019 06:18:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3O4WarA5YSsoGtzkya7AGj0yb0HpmMGwK3nv6sKxsPklujv/y3QIGQ8VhQzmNtjc8kdRP
X-Received: by 2002:a17:906:45ce:: with SMTP id z14mr3183655ejq.144.1561641518204;
        Thu, 27 Jun 2019 06:18:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561641518; cv=none;
        d=google.com; s=arc-20160816;
        b=OR3XfZyMkw5K+R51sconFHH91ii7g4ueQyZOikbQQ3PH+NVPkD4zLDSAmk4CxPYetR
         Ev9jxsQPKLRmd965QO6pcKEM0fdfG9iIOAu2xkcafR+nspdLrSXSXyYbnr55QWwuKoBh
         oVPnZSOGdkDyglooTqYmKX4jwz/sddQccFoMpN2MkkwzCTBY1DuSxQNwL3vQryLP70ok
         MW1KPpuI5neQTXQ7Uyc62OL7wF1r7x906Gw+ykYaK6RQhUvwVoKd4Fs3pBPI3MyWpGoZ
         NFnoBae31oEOyPNGQwvf5305LxqRxDsJ0wOR9IZqs3Re+gMo0mozIVNt7h0tCpIEIioW
         Ur0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=70z2rcphAVlN3RCxXpjlhCAT2xxc48XcyKG/wAa7qjQ=;
        b=LqXjuQ8r/hR+Frb/wtsYN2vJx+Hdtkqnx702NFotDctFEoe21zKOwLA9pTTc5SqQ5n
         yyR+hI/IPTTjiI1GyLkiO4VmRQX0gJhsiMHGa2f5chgojEBZmyjc5qZybqsCiRn83IpI
         tN8XzOcDrGgceJZWpDvY+NwvFF3FPeEUU21qGXjlY1NhYnVCR8w1i8NnKalVbt5uiyt8
         n9gaDosZiy9k+znzDK1wQglAImls5u6hKEXKKnEVkqrYAsiEIJWrV5oU3ODdeeGGX4SR
         b57/sh6Ogcw53AK4ym71lmNCbmgV5J0r3oBJOLyIBfs5+BDYW4TkbmB4IPrkrn0Pn0Ki
         ZqjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of andrew.murray@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=andrew.murray@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w22si1414442eje.322.2019.06.27.06.18.37
        for <linux-mm@kvack.org>;
        Thu, 27 Jun 2019 06:18:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of andrew.murray@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of andrew.murray@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=andrew.murray@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EE85F360;
	Thu, 27 Jun 2019 06:18:36 -0700 (PDT)
Received: from localhost (unknown [10.37.6.20])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6F4D83F246;
	Thu, 27 Jun 2019 06:18:36 -0700 (PDT)
Date: Thu, 27 Jun 2019 14:18:34 +0100
From: Andrew Murray <andrew.murray@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, vincenzo.frascino@arm.com,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [RFC] arm64: Detecting tagged addresses
Message-ID: <20190627131834.GE34530@e119886-lin.cambridge.arm.com>
References: <20190619121619.GV20984@e119886-lin.cambridge.arm.com>
 <20190626174502.GH29672@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626174502.GH29672@arrakis.emea.arm.com>
User-Agent: Mutt/1.10.1+81 (426a6c1) (2018-08-26)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 06:45:03PM +0100, Catalin Marinas wrote:
> Hi Andrew,
> 
> Cc'ing Luc (sparse maintainer) who's been involved in the past
> discussions around static checking of user pointers:
> 
> https://lore.kernel.org/linux-arm-kernel/20180905190316.a34yycthgbamx2t3@ltop.local/
> 
> So I think the difference here from the previous approach is that we
> explicitly mark functions that cannot take tagged addresses (like
> find_vma()) and identify the callers.

Indeed.


> 
> More comments below:
> 
> On Wed, Jun 19, 2019 at 01:16:20PM +0100, Andrew Murray wrote:
> > The proposed introduction of a relaxed ARM64 ABI [1] will allow tagged memory
> > addresses to be passed through the user-kernel syscall ABI boundary. Tagged
> > memory addresses are those which contain a non-zero top byte (the hardware
> > has always ignored this top byte due to TCR_EL1.TBI0) and may be useful
> > for features such as HWASan.
> > 
> > To permit this relaxation a proposed patchset [2] strips the top byte (tag)
> > from user provided memory addresses prior to use in kernel functions which
> > require untagged addresses (for example comparasion/arithmetic of addresses).
> > The author of this patchset relied on a variety of techniques [2] (such as
> > grep, BUG_ON, sparse etc) to identify as many instances of possible where
> > tags need to be stipped.
> > 
> > To support this effort and to catch future regressions (e.g. in new syscalls
> > or ioctls), I've devised an additional approach for detecting the use of
> > tagged addresses in functions that do not want them. This approach makes
> > use of Smatch [3] and is outlined in this RFC. Due to the ability of Smatch
> > to do flow analysis I believe we can annotate the kernel in fewer places
> > than a similar approach in sparse.
> > 
> > I'm keen for feedback on the likely usefulness of this approach.
> > 
> > We first add some new annotations that are exclusively consumed by Smatch:
> > 
> > --- a/include/linux/compiler_types.h
> > +++ b/include/linux/compiler_types.h
> > @@ -19,6 +19,7 @@
> >  # define __cond_lock(x,c)      ((c) ? ({ __acquire(x); 1; }) : 0)
> >  # define __percpu      __attribute__((noderef, address_space(3)))
> >  # define __rcu         __attribute__((noderef, address_space(4)))
> > +# define __untagged    __attribute__((address_space(5)))
> >  # define __private     __attribute__((noderef))
> >  extern void __chk_user_ptr(const volatile void __user *);
> >  extern void __chk_io_ptr(const volatile void __iomem *);
> [...]
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -2224,7 +2224,7 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
> >  EXPORT_SYMBOL(get_unmapped_area);
> >  
> >  /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
> > -struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
> > +struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long __untagged addr)
> >  {
> >         struct rb_node *rb_node;
> >         struct vm_area_struct *vma;
> [...]
> > This can be further improved - the problem here is that for a given function,
> > e.g. find_vma we look for callers where *any* of the parameters
> > passed to find_vma are tagged addresses from userspace - i.e. not *just*
> > the annotated parameter. This is also true for find_vma's callers' callers'.
> > This results in the call tree having false positives.
> > 
> > It *is* possible to track parameters (e.g. find_vma arg 1 comes from arg 3 of
> > do_pages_stat_array etc), but this is limited as if functions modify the
> > data then the tracking is stopped (however this can be fixed).
> [...]
> > An example of a false positve is do_mlock. We untag the address and pass that
> > to apply_vma_lock_flags - however we also pass a length - because the length
> > came from userspace and could have the top bits set - it's flagged. However
> > with improved parameter tracking we can remove this false positive and similar.
> 
> Could we track only the conversions from __user * that eventually end up
> as __untagged? (I'm not familiar with smatch, so not sure what it can
> do).

I assume you mean 'that eventually end up as an argument annotated __untagged'?

The warnings smatch currently produce relate to only the conversions you
mention - however further work is needed in smatch to improve the scripts that
retrospectively provide call traces (without false positives).


> We could assume that an unsigned long argument to a syscall is
> default __untagged, unless explicitly marked as __tagged. For example,
> sys_munmap() is allowed to take a tagged address.

I'll give this some further thought.


> 
> > Prior to smatch I attempted a similar approach with sparse - however it seemed
> > necessary to propogate the __untagged annotation in every function up the call tree,
> > and resulted in adding the __untagged annotation to functions that would never
> > get near user provided data. This leads to a littering of __untagged all over the
> > kernel which doesn't seem appealing.
> 
> Indeed. We attempted this last year (see the above thread).
> 
> > Smatch is more capable, however it almost
> > certainly won't pick up 100% of issues due to the difficulity of making flow
> > analysis understand everything a compiler can.
> > 
> > Is it likely to be acceptable to use the __untagged annotation in user-path
> > functions that require untagged addresses across the kernel?
> 
> If it helps with identifying missing untagged_addr() calls, I would say
> yes (as long as we keep them to a minimum).

Thanks for the feedback.

Andrew Murray

> 
> > [1] https://lkml.org/lkml/2019/6/13/534
> > [2] https://patchwork.kernel.org/cover/10989517/
> > [3] http://smatch.sourceforge.net/
> 
> -- 
> Catalin

