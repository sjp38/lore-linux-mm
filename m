Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32583C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 13:05:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB8DD20717
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 13:05:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB8DD20717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73C866B0274; Tue, 28 May 2019 09:05:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EC2C6B0276; Tue, 28 May 2019 09:05:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DC756B0279; Tue, 28 May 2019 09:05:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 110F86B0274
	for <linux-mm@kvack.org>; Tue, 28 May 2019 09:05:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so2024459ede.0
        for <linux-mm@kvack.org>; Tue, 28 May 2019 06:05:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PKZ76gp/yVpYupXGz47pT+82L05hOr0NPSHNDqqLuAA=;
        b=TuAWfEm7kymFA04wsvS30UJs3F9txEQwAA3ycAaI2IzisxHEC9UCmU1X9WyXbKPHSp
         IsBQkVP6J1J0OI5BA1Jqcr5orqxAg9zbVtIGAiP81YaPak3av9EfpawoQS2bbGn95EEU
         In5swc/aM4vvYzpzspJMfAQj5WFKj7jMPMRsGn3HaBibZC9GaScrG3CDun49airBEk18
         Bao8PwLDN4R2cJFVK4sZ17zc/XwnPP4m5f2RErWpFvhCmIH77GDU5nprLjAfCyQOcv96
         11w+qrR3GwBIjAeRHxblg+jsxrTOWoJU/b83nEWS/Y8kbgLi656xS6v5V/bZeqnz/XDp
         wSRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXBZZFUX7H419I/NVV46HnwiI19j24nnD7HXKa1D9qigsiN9fon
	LJ/qEkEPjSMrOavINjoyLPQgXQI/TlZwZyxYMUNctiJed7f8RZOOjuao2TrTeC3m0Z3r3RxGq3Q
	DHR4yYs8aHYkCQG/4tDzUFeKYnQw10zZ/jPqahP+teJHD8OJxD1a0IoRCY4ah4C/00A==
X-Received: by 2002:a50:9430:: with SMTP id p45mr126623594eda.257.1559048729647;
        Tue, 28 May 2019 06:05:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCsBBrZ0deQoLhsojc97SfCWNITPzlqY+2IB7r7YYLvM4G6BujxGbd3YRQlDCcSnlaHA5k
X-Received: by 2002:a50:9430:: with SMTP id p45mr126623444eda.257.1559048728359;
        Tue, 28 May 2019 06:05:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559048728; cv=none;
        d=google.com; s=arc-20160816;
        b=ptn4DQmXxIQ/S8vAULKGApb9ONkFaDyscXq2iSXAokTpa6ac6bSwwyfsfONgUjNren
         ePhom4ZHfnqqR796pamOr9FH608vNO7q61xx5/jhLe3oUvk6fC5TNManlW01Yyxp0EUv
         1efXla3uaJKZJ7EoKX5LqnbxIGfltVrEa0jJNMS+RFe1k9aYbWwyUiGBwnLxtIQ2I346
         j72gGup4Ba6rpYxdSpSjW0HNGx7IesTAeVVr/OjL3gnStgHuQDqZqb1mq9450H+eRvin
         x87Mgw8NJKGkTVdj5FTTp3tthEToC5rOWUnBE4M+63tN7gtGMgBZG66DKTixZGcqtWPB
         KbDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PKZ76gp/yVpYupXGz47pT+82L05hOr0NPSHNDqqLuAA=;
        b=mL2Yc0bFEaMG8aLW4Hvq1aTyAGYDkUPqZ1eufJ9848Wz+aEsK93Ln2SpBf6XjxGoJr
         DB4cCoiAM6T6SDLm+Z519BycI4D2NkxjqLrIUeJkDU2VMRd1/OcWiZd2JoBrpT4g8SD/
         LgwZGm5kv/IUop2qG2BU9q70NJe7zEKhIs8f606d17nK29edtTo4RV6XaMlRGKtTrDpR
         NEAs9kvM0/o9qLKBxNNGTOno40DN2vCn7j5VoFLGg74F/EGpkozAt4RmZfUFRAC4TDTh
         QCAoX4lPXSqtS02fmrdiRB6RvMH8UokV19rOPPzKDo1RJfPGFT2D8B4bqWNFJladwEPB
         Xhmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l27si1978793edd.52.2019.05.28.06.05.27
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 06:05:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D01EC80D;
	Tue, 28 May 2019 06:05:26 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 479923F5AF;
	Tue, 28 May 2019 06:05:21 -0700 (PDT)
Date: Tue, 28 May 2019 14:05:18 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190528130518.GB32006@arrakis.emea.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
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

This hunk should be (I sent a separate patch for sys_personality):

@@ -160,23 +163,23 @@ SYSCALL_DEFINE1(arm64_shmdt, char __user *, shmaddr)
 /*
  * Wrappers to pass the pt_regs argument.
  */
-#define sys_personality		sys_arm64_personality
-#define sys_mmap_pgoff		sys_arm64_mmap_pgoff
-#define sys_mremap		sys_arm64_mremap
-#define sys_munmap		sys_arm64_munmap
-#define sys_brk			sys_arm64_brk
-#define sys_get_mempolicy	sys_arm64_get_mempolicy
-#define sys_madvise		sys_arm64_madvise
-#define sys_mbind		sys_arm64_mbind
-#define sys_mlock		sys_arm64_mlock
-#define sys_mlock2		sys_arm64_mlock2
-#define sys_munlock		sys_arm64_munlock
-#define sys_mprotect		sys_arm64_mprotect
-#define sys_msync		sys_arm64_msync
-#define sys_mincore		sys_arm64_mincore
-#define sys_remap_file_pages	sys_arm64_remap_file_pages
-#define sys_shmat		sys_arm64_shmat
-#define sys_shmdt		sys_arm64_shmdt
+#define __arm64_sys_personality		__arm64_sys_arm64_personality
+#define __arm64_sys_mmap_pgoff		__arm64_sys_arm64_mmap_pgoff
+#define __arm64_sys_mremap		__arm64_sys_arm64_mremap
+#define __arm64_sys_munmap		__arm64_sys_arm64_munmap
+#define __arm64_sys_brk			__arm64_sys_arm64_brk
+#define __arm64_sys_get_mempolicy	__arm64_sys_arm64_get_mempolicy
+#define __arm64_sys_madvise		__arm64_sys_arm64_madvise
+#define __arm64_sys_mbind		__arm64_sys_arm64_mbind
+#define __arm64_sys_mlock		__arm64_sys_arm64_mlock
+#define __arm64_sys_mlock2		__arm64_sys_arm64_mlock2
+#define __arm64_sys_munlock		__arm64_sys_arm64_munlock
+#define __arm64_sys_mprotect		__arm64_sys_arm64_mprotect
+#define __arm64_sys_msync		__arm64_sys_arm64_msync
+#define __arm64_sys_mincore		__arm64_sys_arm64_mincore
+#define __arm64_sys_remap_file_pages	__arm64_sys_arm64_remap_file_pages
+#define __arm64_sys_shmat		__arm64_sys_arm64_shmat
+#define __arm64_sys_shmdt		__arm64_sys_arm64_shmdt
 
 asmlinkage long sys_ni_syscall(const struct pt_regs *);
 #define __arm64_sys_ni_syscall	sys_ni_syscall

-- 
Catalin

