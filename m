Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2A83C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:41:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B5382183E
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 15:41:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B5382183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD3406B0003; Fri, 22 Mar 2019 11:41:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C81336B0006; Fri, 22 Mar 2019 11:41:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4A166B0007; Fri, 22 Mar 2019 11:41:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 668E36B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:41:50 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h27so1119648eda.8
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:41:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mfMsdSyeB3waNaJmV2fPO4V8Fh67DZpwBQWP1tECuc4=;
        b=UuPhU4A/Br83GptDWKdVeeZ9xFPlhl+eK6AtXu3GxEiBJ7xFwKPTYoDYcmDBtHm2gT
         i+G8S+1f0598Iz7t4tAIqsNJFuyvRo5aFjK2kJ3p2pRF7dAVoduwOaBOyE6MeyNvqZvt
         6KP9rtT3VqAdwPh96TecIUYtJDL9SC7WRAxydf5x6YMggZBPZSTXloEbPPzE4EfFPyOu
         v+87jiAqR8gaDQEtX45w21HN4Pn8w0Py6Q5QzqYabC5UbVWwvA6mIVOm5wA8qXFYPk28
         xqxdqkIOZJ4Q31YuqFFTrz/b9xMwCS/Sg4PMb35IxfIztQ6GrmG/dD/84TyIOH0QqH61
         0F0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWMksW7vBI30qHoUxnbCbDtt5eokD0f0KdSrB5Hv1pC2wZXbhIN
	QKjAfzgHSrZcSNqwgAxQS+iun/XgtAIMn/0GklS3OIkJWyLAgTF2czq7qVql7ClMmHhBOqfdzRZ
	plyeGZvtqZCwrBAyz7KOgPZUEgyaWRgtBO3GPRo2gN3eHvScVp4dgEoWoL2GqVjnl7w==
X-Received: by 2002:a50:b8a5:: with SMTP id l34mr6805246ede.196.1553269309939;
        Fri, 22 Mar 2019 08:41:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAaPlqUTrKJcuniGyaKqyZa9yutIypTlzSwGMch/m/EbGXpKvPKawUfU/UPdGAL3PeWqCL
X-Received: by 2002:a50:b8a5:: with SMTP id l34mr6805195ede.196.1553269308785;
        Fri, 22 Mar 2019 08:41:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553269308; cv=none;
        d=google.com; s=arc-20160816;
        b=ZoBjDOp0OneR2Edif+9kxmAMgEpl7UWCSfxYp4bpzAZmWUvj0gD4stQWs5iST8QNZK
         BocXxxPWornws+pXuxOlDdjBDCl6kD2Qsdca0i7CAX0DNdqcqKFguSlU0oVCB1fSe6Oo
         Xf74dVwxSkv1yp9+ug48NpghB3Pj/JQFc+UH9gPyIuFTsSiK0bZPglpXGb6tFBaNjkVC
         yHwxYBcu9/1b+jkShW7fzBLL/Hip9kfgOkfewdbU4m4XDjdoq/FQ9VC4nV64HOIxm7e4
         CVBqHpWAXfFHu16/zk0R+KJw8pYwfOMhvKlZKgq1RcJHZ2fBDzWuJp68kIzjiuv3Ps93
         TEVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mfMsdSyeB3waNaJmV2fPO4V8Fh67DZpwBQWP1tECuc4=;
        b=t+/Hta1jHFQrDyH35NkPug5n31x3XwendQqi4he9hKPV0wBK8n9UFw9+e7DkeNze0Z
         nxx5VtEPXKPVfq1jF1YNQyBGZHwm4g3N48ksuNcl/S6S6H7+aO8y2L4qSd1xUQuAOdmy
         hAWhw/mlKoOcs2m8e5OACRTgZW1SyXdz4pmaipA3FCsK10/2SpvrGgZl1lNrnmL3mN+1
         tEsnBeUU0h4OF5mCZ4GWxoOzoY4vJC9By2r5j/WgkG0X1Evr5RKOyusGksP69zygAfSb
         bb+50mVtVKvC2Hg0ReV6unn/Cy10OpnHL9yocJCcsRywEID4CarlNpyz1uK9pitpL2De
         e3Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r25si2977431edb.15.2019.03.22.08.41.48
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 08:41:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 62775A78;
	Fri, 22 Mar 2019 08:41:47 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7CB833F59C;
	Fri, 22 Mar 2019 08:41:39 -0700 (PDT)
Date: Fri, 22 Mar 2019 15:41:37 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	bpf@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 10/20] kernel, arm64: untag user pointers in
 prctl_set_mm*
Message-ID: <20190322154136.GP13384@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <76f96eb9162b3a7fa5949d71af38bf8fdf6924c4.1553093421.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <76f96eb9162b3a7fa5949d71af38bf8fdf6924c4.1553093421.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:51:24PM +0100, Andrey Konovalov wrote:
> @@ -2120,13 +2135,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  	if (opt == PR_SET_MM_AUXV)
>  		return prctl_set_auxv(mm, addr, arg4);
>  
> -	if (addr >= TASK_SIZE || addr < mmap_min_addr)
> +	if (untagged_addr(addr) >= TASK_SIZE ||
> +			untagged_addr(addr) < mmap_min_addr)
>  		return -EINVAL;
>  
>  	error = -EINVAL;
>  
>  	down_write(&mm->mmap_sem);
> -	vma = find_vma(mm, addr);
> +	vma = find_vma(mm, untagged_addr(addr));
>  
>  	prctl_map.start_code	= mm->start_code;
>  	prctl_map.end_code	= mm->end_code;

Does this mean that we are left with tagged addresses for the
mm->start_code etc. values? I really don't think we should allow this,
I'm not sure what the implications are in other parts of the kernel.

Arguably, these are not even pointer values but some address ranges. I
know we decided to relax this notion for mmap/mprotect/madvise() since
the user function prototypes take pointer as arguments but it feels like
we are overdoing it here (struct prctl_mm_map doesn't even have
pointers).

What is the use-case for allowing tagged addresses here? Can user space
handle untagging?

-- 
Catalin

