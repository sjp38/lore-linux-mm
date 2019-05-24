Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0F2DC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:41:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 861FE217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:41:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 861FE217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 530746B000A; Fri, 24 May 2019 11:41:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5070B6B000C; Fri, 24 May 2019 11:41:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F6A76B000D; Fri, 24 May 2019 11:41:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E50766B000A
	for <linux-mm@kvack.org>; Fri, 24 May 2019 11:41:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n52so14790758edd.2
        for <linux-mm@kvack.org>; Fri, 24 May 2019 08:41:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wKF22SQo4AS5kLzAro1iK+gehsaUDMPc3CppRMlj0I0=;
        b=tHpp/zvsfG23ME5Af5Mfibe/vXrqwCw9xhtc3QkArsexZPIMV7G+RgfM5Xylv9IT/p
         c6RHdpbwZZ4nW6cz83Q7cO5dygX0VAuffgKYnm4XfBhFSi4TLwKIpjbypohruLo7Y4yZ
         crUA642sgBqkJFo+M0BzvJsRwAjv37zzq854i9uoTg8yshEdjhjfyrXoEb1Il2jQeVo+
         aE1QCg5UTDyGvVqWnrTjEl2VOWMRmLNVwA2rzBD1CEkGIp44gIHeyhUAIVccDACJ2gWj
         PK2woop+Z85Hn7LDmmHHw3/ZMZ36zSct4lcrzNyi6kb25+7NQzpHwUaYhJOOy5c3GB3n
         9hVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of andrew.murray@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=andrew.murray@arm.com
X-Gm-Message-State: APjAAAWgsGaO/89ksTgb5yBeTnmwm8lrZ51CUKZSKwHFTG1jnd/z2M8b
	blhefQWtZx+vyzXQvIeZUFUwmQUINNAZJiUHAykG6rv5xpeBf2R2t9zx83PR92O2ngS6HXGNbVd
	Kbj382OpIxLtOUtQN8oIBZPLYWZvw+1KP3riieQJ9SJSbVX9iBVL+LW438gN2VSbUFw==
X-Received: by 2002:a50:99ca:: with SMTP id n10mr105736200edb.279.1558712508492;
        Fri, 24 May 2019 08:41:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznggf5FNPExanxt9vj34rq2dTCr0g3mpffau3YDv4Zj8b0duXMJLylUuleMRHgAN0sg8jB
X-Received: by 2002:a50:99ca:: with SMTP id n10mr105736105edb.279.1558712507637;
        Fri, 24 May 2019 08:41:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558712507; cv=none;
        d=google.com; s=arc-20160816;
        b=gEkn+1EKojNm9mPPfyi4JQh7pkxCFv0J7SDvMM1PIBqfj5R2N7vzrmc9Nis3JpYgQn
         XFmfB74WHvF2nun3jI12r+HMrOdc5YYMnibN79lehzMfY8uZ3lXOD6Hnj6I10r8xVUoz
         XI3SExEibQt85UOyU8DdmwV+X8L/NeSPqnPrzQThd3g19UxLnnVgFlFU5f7QM8SHkrXv
         TibFuLm7tWrdfNRuWyFbRPINUU8Dfu76dkbn+n6C01DtAeC7fFuSM0C63A7hDr9GNmAK
         KR8bKvkPwrkGeDB869ydLuEjekT6scFpuoYXDFGhSI9wsfYrj8zTvxueHvkHy7Xvk0K/
         n1Ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wKF22SQo4AS5kLzAro1iK+gehsaUDMPc3CppRMlj0I0=;
        b=WLf5KPEdWPxAPl/DoNQGqhA/yzdG/p57/cs+h9vqQlDIAOaabUxvNy44b4UGW6D3e8
         gK5tG9c3QZLrSL9A97DNHY2wnJ64878x3unIttaT1Tw3ffMeD0/oqfY13o6zpBr/bkyP
         dDYRUovKi7+LN0td0KBxCiofardF7qF01xnZON4h7rNAkojLXNe14mQLU2hLCDBtZ57i
         zvQaicCPtPjfaBoEnVJStPpFvFu1wmjFfNNCjACRXHgDWxfxlHZSvSGmLt5ioxFLg/dm
         DCxeYbhZkaCrwPpm7hZG73ELunt+v3xg70gSPItjZQ6FuGGzd11KoAEELThgldCHATev
         u01A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of andrew.murray@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=andrew.murray@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e7si2008694edd.301.2019.05.24.08.41.47
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 08:41:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of andrew.murray@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of andrew.murray@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=andrew.murray@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 72E5C15A2;
	Fri, 24 May 2019 08:41:46 -0700 (PDT)
Received: from localhost (unknown [10.37.6.20])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DC68A3F575;
	Fri, 24 May 2019 08:41:45 -0700 (PDT)
Date: Fri, 24 May 2019 16:41:44 +0100
From: Andrew Murray <andrew.murray@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Mark Rutland <mark.rutland@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190524154143.GG8268@e119886-lin.cambridge.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1+81 (426a6c1) (2018-08-26)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> This patch allows tagged pointers to be passed to the following memory
> syscalls: brk, get_mempolicy, madvise, mbind, mincore, mlock, mlock2,
> mmap, mmap_pgoff, mprotect, mremap, msync, munlock, munmap,
> remap_file_pages, shmat and shmdt.
> 
> This is done by untagging pointers passed to these syscalls in the
> prologues of their handlers.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---


> +SYSCALL_DEFINE2(arm64_mlock, unsigned long, start, size_t, len)
> +{
> +	start = untagged_addr(start);
> +	return ksys_mlock(start, len, VM_LOCKED);
> +}
> +
> +SYSCALL_DEFINE2(arm64_mlock2, unsigned long, start, size_t, len)
> +{
> +	start = untagged_addr(start);
> +	return ksys_mlock(start, len, VM_LOCKED);
> +}

I think this may be a copy/paste error...

Shouldn't mlock2 have a third 'flags' argument to distinguish is from mlock?

Thanks,

Andrew Murray

> +
> +SYSCALL_DEFINE2(arm64_munlock, unsigned long, start, size_t, len)
> +{
> +	start = untagged_addr(start);
> +	return ksys_munlock(start, len);
> +}
> +
> +SYSCALL_DEFINE3(arm64_mprotect, unsigned long, start, size_t, len,
> +		unsigned long, prot)
> +{
> +	start = untagged_addr(start);
> +	return ksys_mprotect_pkey(start, len, prot, -1);
> +}
> +
> +SYSCALL_DEFINE3(arm64_msync, unsigned long, start, size_t, len, int, flags)
> +{
> +	start = untagged_addr(start);
> +	return ksys_msync(start, len, flags);
> +}
> +
> +SYSCALL_DEFINE3(arm64_mincore, unsigned long, start, size_t, len,
> +		unsigned char __user *, vec)
> +{
> +	start = untagged_addr(start);
> +	return ksys_mincore(start, len, vec);
> +}
> +
> +SYSCALL_DEFINE5(arm64_remap_file_pages, unsigned long, start,
> +		unsigned long, size, unsigned long, prot,
> +		unsigned long, pgoff, unsigned long, flags)
> +{
> +	start = untagged_addr(start);
> +	return ksys_remap_file_pages(start, size, prot, pgoff, flags);
> +}
> +
> +SYSCALL_DEFINE3(arm64_shmat, int, shmid, char __user *, shmaddr, int, shmflg)
> +{
> +	shmaddr = untagged_addr(shmaddr);
> +	return ksys_shmat(shmid, shmaddr, shmflg);
> +}
> +
> +SYSCALL_DEFINE1(arm64_shmdt, char __user *, shmaddr)
> +{
> +	shmaddr = untagged_addr(shmaddr);
> +	return ksys_shmdt(shmaddr);
> +}
> +
>  /*
>   * Wrappers to pass the pt_regs argument.
>   */
>  #define sys_personality		sys_arm64_personality
> +#define sys_mmap_pgoff		sys_arm64_mmap_pgoff
> +#define sys_mremap		sys_arm64_mremap
> +#define sys_munmap		sys_arm64_munmap
> +#define sys_brk			sys_arm64_brk
> +#define sys_get_mempolicy	sys_arm64_get_mempolicy
> +#define sys_madvise		sys_arm64_madvise
> +#define sys_mbind		sys_arm64_mbind
> +#define sys_mlock		sys_arm64_mlock
> +#define sys_mlock2		sys_arm64_mlock2
> +#define sys_munlock		sys_arm64_munlock
> +#define sys_mprotect		sys_arm64_mprotect
> +#define sys_msync		sys_arm64_msync
> +#define sys_mincore		sys_arm64_mincore
> +#define sys_remap_file_pages	sys_arm64_remap_file_pages
> +#define sys_shmat		sys_arm64_shmat
> +#define sys_shmdt		sys_arm64_shmdt
>  
>  asmlinkage long sys_ni_syscall(const struct pt_regs *);
>  #define __arm64_sys_ni_syscall	sys_ni_syscall
> -- 
> 2.21.0.1020.gf2820cf01a-goog
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

