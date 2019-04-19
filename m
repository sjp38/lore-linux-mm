Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0213C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 10:56:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E89B2190A
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 10:56:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E89B2190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEC266B0003; Fri, 19 Apr 2019 06:56:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D73D96B0006; Fri, 19 Apr 2019 06:56:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3C126B0007; Fri, 19 Apr 2019 06:56:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 72B0C6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 06:56:19 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t82so4421922wmg.8
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 03:56:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=qIQ9WMcBNJ0tg5n81lCR8/VIPfVjFMRggN0bApVKx8s=;
        b=kG1YdwFnUYUNCjVeirnAvyZZX1ybo2p00qjplu/U90kbktWF8h9nFiik5gO0Tnw5Ls
         AqzNgLFiLQO1qK1uoAFq6+6AwkAFKFgJZjAO7+aGxYL5cQ5kdbfDwy/0TA1dKsBDnUXt
         DhyZJAQlE1KJy1h/XtmKoCztYf/h8t4AqrZMvEZ9htTBKPmTLYAWI1GnGTKfhM1EOgN2
         Zix507YYgfjInFbrx19SEvkvIUXGDHNnsiTsk5UHm0agcIghVR3XNq/LKQqXt2vRzX/H
         g7bJ40xcLVxcX5p1bwdiqsOQWLkXDX0YZQX51ZVloVFRjUTqRe7lpXrqoxh2ox5vampp
         z86g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXpUN5sn//pURoaB3FdwcceE2n0gG2CivoC2oOOnbZWITG+iCc3
	KYS6Ypju5A36TzgO15LwV8jKpRJAnrzpIVTjJIUp5hRC6vHwUOuZDHwVStAtJ+XfoATCKaDKuXu
	wFPj/+ZjpG5dIvut3hIfFp+ZMnBHaSR5k6CDR2XfaysWSDswte5MikwMX0EyZYWhH/g==
X-Received: by 2002:a1c:6308:: with SMTP id x8mr2264328wmb.147.1555671378994;
        Fri, 19 Apr 2019 03:56:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdYmqh6eDjzeY97cAqbocKtdaPicNxxr9i0vc0VCkrZ1Jf0lwiDX1v1Ra4XfTUtCUjLJNj
X-Received: by 2002:a1c:6308:: with SMTP id x8mr2264288wmb.147.1555671378024;
        Fri, 19 Apr 2019 03:56:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555671378; cv=none;
        d=google.com; s=arc-20160816;
        b=qY0DN+Xeq3ss8sMx+TrTihqoT5Ulpcgb0TNOoJFhqprogheFBW9LzkT/knSOUkCCYJ
         B9XVsSEJ2NZgxYwYFczyVBVprdfGBTwp3C6Mqec4A/t+86ETXRtUKRulLo3jYsWwUch3
         qPw8S7ekduSv7/iZ7Yi4GSCi0cmS7qPKlHorzwmbZr3YGwN6RVWvLHxyTYAekle1aXqd
         qdRcHOxfrNi2orsOaWfCDsfqOikZDb9DbOmyJgjDHnU/LEpOWN8S9hO7PhWBCZtXxjS1
         l6G9lLl+bjqMxGzPWSzScf3TWmyDHmQm/hg6USgvxRkVNyWg0a3UEyPmAT51tTwvtEfl
         zDTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=qIQ9WMcBNJ0tg5n81lCR8/VIPfVjFMRggN0bApVKx8s=;
        b=D5eTwoHWjIrKdWrDZnSCiV8fV5gPxrIRoRu0XzBy8cFElHnSbby4HSiWqrJMI3apL8
         D+xIbAVqS3YD5/YjIhbnb7CFq+x7XUK4a99y4zf/TlezyQkx2DfR5lxN23Z9plc/qXLI
         DT41HPQg7Eo/W7lfZNb+7uvAC8xRxil/iI2bYuM6hYCttejjRQpT4v/zXfPRhPMpMcJU
         qggm77mdxumvqp0J72E4C5+7i2jmJngfsnsD4na3ZlonjTRtO2OGnm3TB+PzzrQ4G0TA
         63T90zsC8civRRBV7VBYMGt7GZ7Ku93fofKWxFca0jkjkdvE/wPBy38uJ4b4eA9joHNb
         ZMEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u9si1621982wrr.310.2019.04.19.03.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 19 Apr 2019 03:56:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hHRBB-0002lN-E1; Fri, 19 Apr 2019 12:55:37 +0200
Date: Fri, 19 Apr 2019 12:55:36 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Dave Hansen <dave.hansen@linux.intel.com>
cc: LKML <linux-kernel@vger.kernel.org>, rguenther@suse.de, mhocko@suse.com, 
    vbabka@suse.cz, luto@amacapital.net, x86@kernel.org, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    stable@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] x86/mpx: fix recursive munmap() corruption
In-Reply-To: <20190401141549.3F4721FE@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.21.1904191248090.3174@nanos.tec.linutronix.de>
References: <20190401141549.3F4721FE@viggo.jf.intel.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Apr 2019, Dave Hansen wrote:
> diff -puN mm/mmap.c~mpx-rss-pass-no-vma mm/mmap.c
> --- a/mm/mmap.c~mpx-rss-pass-no-vma	2019-04-01 06:56:53.409411123 -0700
> +++ b/mm/mmap.c	2019-04-01 06:56:53.423411123 -0700
> @@ -2731,9 +2731,17 @@ int __do_munmap(struct mm_struct *mm, un
>  		return -EINVAL;
>  
>  	len = PAGE_ALIGN(len);
> +	end = start + len;
>  	if (len == 0)
>  		return -EINVAL;
>  
> +	/*
> +	 * arch_unmap() might do unmaps itself.  It must be called
> +	 * and finish any rbtree manipulation before this code
> +	 * runs and also starts to manipulate the rbtree.
> +	 */
> +	arch_unmap(mm, start, end);

...
  
> -static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
> -			      unsigned long start, unsigned long end)
> +static inline void arch_unmap(struct mm_struct *mm, unsigned long start,
> +			      unsigned long end)

While you fixed up the asm-generic thing, this breaks arch/um and
arch/unicorn32. For those the fixup is trivial by removing the vma
argument.

But itt also breaks powerpc and there I'm not sure whether moving
arch_unmap() to the beginning of __do_munmap() is safe. Micheal???

Aside of that the powerpc variant looks suspicious:

static inline void arch_unmap(struct mm_struct *mm,
                              unsigned long start, unsigned long end)
{
 	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
                mm->context.vdso_base = 0;
}

Shouldn't that be: 

 	if (start >= mm->context.vdso_base && mm->context.vdso_base < end)

Hmm?

Thanks,

	tglx

