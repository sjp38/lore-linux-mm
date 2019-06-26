Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D17E3C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:45:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A7DA21670
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:45:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A7DA21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3B526B0003; Wed, 26 Jun 2019 13:45:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEC788E0003; Wed, 26 Jun 2019 13:45:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB45A8E0002; Wed, 26 Jun 2019 13:45:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5EE6B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 13:45:09 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so4048296edd.22
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:45:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1EyjEwKbkzTT+BznoIxUOjPzT3JO0ngfeCNwWd4ZyyM=;
        b=UUcwERlAaDmO37pnB1Aa7GX9thfG+esDU4HaGk+VGC8rSYdORosRsgzI8VPkiT87OH
         w9BOLMYovdPfrdFBlHiJwaALGGHbfepkfhEYT9hll5dZ+0yZ342j7cqV5I+FZJVw6C3a
         6skMEHaJ76fKaRt6whZwZ//YNKYaKSnEv1CC9Nqx0qiWahang1B7OhM/+VmQnhV4CvlI
         PnmxsWEg8auIK6mjyS8bI611QxybMjG74qbGnMFh/IoR9JKEuzUxhgeIV2ZME73dUgxI
         9rHaYtDCryrwP2ogpArnxlZXiapHTsa8+chQsFsGil4Z/69pzR92iet6gL7Rl5dh11dV
         IhgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUi6oKm8m5uTgCV4KF8a0If1otQQlsYJPcOOnaCw1gai8KjGTU3
	JCgvCN0IOyTYfJjpCeWXJlfDHekIGm5zW4lNuw2T9Piepo6AXagt4RSWWF3Wria2udBw09ANG0v
	tWtcN6vXeULqz977ZCoJJKqFmjwgE95CBhQON9DYy/11dyx6mtzNr3Zim+4kkoEMO9w==
X-Received: by 2002:a50:aeaf:: with SMTP id e44mr7023476edd.239.1561571109038;
        Wed, 26 Jun 2019 10:45:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEZ6X1ymRiAb5HLDs2Svd8yXJv/+g5fXzN1I3ZJyW0Jhkxvg02pF4YrLJUbV1bjeFhKFXk
X-Received: by 2002:a50:aeaf:: with SMTP id e44mr7023382edd.239.1561571108038;
        Wed, 26 Jun 2019 10:45:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561571108; cv=none;
        d=google.com; s=arc-20160816;
        b=zRhk/phumb2AXvHLRLbjRIZ5Sq51Sb66OmU+DGTqf/HwTw7wY+j2wdPOrvyl4qksJb
         vrIsZH9SC2P9n0RWWaL4KdQe6Rkdn5qxNK7tPZBT+KkyzpAo8FIe5GEIDie+7bm7RFMZ
         35Y11B4xwsRByvhIfcd6fUgmbEDf031ZIsjTEO3P1HH44j6WYPchWNDqm3dKM2v1DulO
         INxCwdnHeEUFZcqI5q20Swsrz94aBzmNN39sMI0Zecw0PGQF7jEMG7T2qouEu/lfo0K+
         cArfUlSUvyZHOFZlStJTsh3WGUTuijpVdoUEi68ZrmJHRAAgAxE+eZK7EwxYIg2KZbMf
         yA1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1EyjEwKbkzTT+BznoIxUOjPzT3JO0ngfeCNwWd4ZyyM=;
        b=fVcgEi48ZPClzoevOFMx5M9KtFyTiHpWy8L0bbn73ElGtbqtwtCfZPMk2VEz1ViJWi
         t3cDanKe9sp8YnypGE8h6rUbofsHWAOA9GtBoUU3eFDh+GBXhtX5m31e5vG1QncUHokR
         beWh8qaqZ4GqQW/YrMRGdZZ2KZeS1DDXOflK8Gi+x+PruazT/2VTduSBzsgh+kDR2r+W
         sHc6tGntmPW+YrT7/lGiJ9aos1tV4yOnW3yByIwOD5iRDf8tXJ/lxy/bXulD9v0sU+sW
         x6CNjtn2qyjkQVj5FKcxWwN0KCj12/9GxkT24+GSu/EOwxdJ5VY/y3pyQql7WOO5n3K/
         TPAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id bq1si3166745ejb.209.2019.06.26.10.45.07
        for <linux-mm@kvack.org>;
        Wed, 26 Jun 2019 10:45:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8098A360;
	Wed, 26 Jun 2019 10:45:06 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5FA693F718;
	Wed, 26 Jun 2019 10:45:05 -0700 (PDT)
Date: Wed, 26 Jun 2019 18:45:03 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrew Murray <andrew.murray@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, vincenzo.frascino@arm.com,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [RFC] arm64: Detecting tagged addresses
Message-ID: <20190626174502.GH29672@arrakis.emea.arm.com>
References: <20190619121619.GV20984@e119886-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619121619.GV20984@e119886-lin.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Cc'ing Luc (sparse maintainer) who's been involved in the past
discussions around static checking of user pointers:

https://lore.kernel.org/linux-arm-kernel/20180905190316.a34yycthgbamx2t3@ltop.local/

So I think the difference here from the previous approach is that we
explicitly mark functions that cannot take tagged addresses (like
find_vma()) and identify the callers.

More comments below:

On Wed, Jun 19, 2019 at 01:16:20PM +0100, Andrew Murray wrote:
> The proposed introduction of a relaxed ARM64 ABI [1] will allow tagged memory
> addresses to be passed through the user-kernel syscall ABI boundary. Tagged
> memory addresses are those which contain a non-zero top byte (the hardware
> has always ignored this top byte due to TCR_EL1.TBI0) and may be useful
> for features such as HWASan.
> 
> To permit this relaxation a proposed patchset [2] strips the top byte (tag)
> from user provided memory addresses prior to use in kernel functions which
> require untagged addresses (for example comparasion/arithmetic of addresses).
> The author of this patchset relied on a variety of techniques [2] (such as
> grep, BUG_ON, sparse etc) to identify as many instances of possible where
> tags need to be stipped.
> 
> To support this effort and to catch future regressions (e.g. in new syscalls
> or ioctls), I've devised an additional approach for detecting the use of
> tagged addresses in functions that do not want them. This approach makes
> use of Smatch [3] and is outlined in this RFC. Due to the ability of Smatch
> to do flow analysis I believe we can annotate the kernel in fewer places
> than a similar approach in sparse.
> 
> I'm keen for feedback on the likely usefulness of this approach.
> 
> We first add some new annotations that are exclusively consumed by Smatch:
> 
> --- a/include/linux/compiler_types.h
> +++ b/include/linux/compiler_types.h
> @@ -19,6 +19,7 @@
>  # define __cond_lock(x,c)      ((c) ? ({ __acquire(x); 1; }) : 0)
>  # define __percpu      __attribute__((noderef, address_space(3)))
>  # define __rcu         __attribute__((noderef, address_space(4)))
> +# define __untagged    __attribute__((address_space(5)))
>  # define __private     __attribute__((noderef))
>  extern void __chk_user_ptr(const volatile void __user *);
>  extern void __chk_io_ptr(const volatile void __iomem *);
[...]
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2224,7 +2224,7 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
>  EXPORT_SYMBOL(get_unmapped_area);
>  
>  /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
> -struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
> +struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long __untagged addr)
>  {
>         struct rb_node *rb_node;
>         struct vm_area_struct *vma;
[...]
> This can be further improved - the problem here is that for a given function,
> e.g. find_vma we look for callers where *any* of the parameters
> passed to find_vma are tagged addresses from userspace - i.e. not *just*
> the annotated parameter. This is also true for find_vma's callers' callers'.
> This results in the call tree having false positives.
> 
> It *is* possible to track parameters (e.g. find_vma arg 1 comes from arg 3 of
> do_pages_stat_array etc), but this is limited as if functions modify the
> data then the tracking is stopped (however this can be fixed).
[...]
> An example of a false positve is do_mlock. We untag the address and pass that
> to apply_vma_lock_flags - however we also pass a length - because the length
> came from userspace and could have the top bits set - it's flagged. However
> with improved parameter tracking we can remove this false positive and similar.

Could we track only the conversions from __user * that eventually end up
as __untagged? (I'm not familiar with smatch, so not sure what it can
do). We could assume that an unsigned long argument to a syscall is
default __untagged, unless explicitly marked as __tagged. For example,
sys_munmap() is allowed to take a tagged address.

> Prior to smatch I attempted a similar approach with sparse - however it seemed
> necessary to propogate the __untagged annotation in every function up the call tree,
> and resulted in adding the __untagged annotation to functions that would never
> get near user provided data. This leads to a littering of __untagged all over the
> kernel which doesn't seem appealing.

Indeed. We attempted this last year (see the above thread).

> Smatch is more capable, however it almost
> certainly won't pick up 100% of issues due to the difficulity of making flow
> analysis understand everything a compiler can.
> 
> Is it likely to be acceptable to use the __untagged annotation in user-path
> functions that require untagged addresses across the kernel?

If it helps with identifying missing untagged_addr() calls, I would say
yes (as long as we keep them to a minimum).

> [1] https://lkml.org/lkml/2019/6/13/534
> [2] https://patchwork.kernel.org/cover/10989517/
> [3] http://smatch.sourceforge.net/

-- 
Catalin

