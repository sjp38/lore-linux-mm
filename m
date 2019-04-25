Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E917FC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:48:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDAB620717
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:48:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="i7Hq0H2F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDAB620717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41CF46B0005; Thu, 25 Apr 2019 16:48:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A5E66B0006; Thu, 25 Apr 2019 16:48:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 247146B0008; Thu, 25 Apr 2019 16:48:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC4636B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:48:27 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b8so462326pls.22
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:48:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FitD4X1vPtPf9AaJyZflnefh5ZXat3I/abaTtFAMS7o=;
        b=dgAmC+JZOX74ydOZPppGhwj/FEzsB0a2NWP1/Ynn/spD3Rlmlow43mTUoSIxr5PD88
         Ze6n7NJPPPLF85I8zTSjC2EGkM2c+pDTfkp/DoO9CIVJCp/BWZ3fseAkpBGEjTZyA5c3
         riN6x0XxzEeo1x8hkDULytDVRfWtfwV8rO26OcmbMU3zRKeH5+bkHstK3dFgzrRBfGM6
         DtevJYzSOncJqfjAESnBdaulvsrxij1mM+hR3OwCE5d1LFPnXGErNOEKfOyWxzzxhQCy
         gawTBnSam4PJ+IDwz+15YZ3lpse1jpTk7uA7rwz9ktPCQWWMH6aDPZXDYTHIZemQpgaN
         ko1w==
X-Gm-Message-State: APjAAAUn5k3tZmr75BgFpmkqUVl02VoKmZLaxjoaqyEU+tPOe88VPFCE
	HjL8nePPbJBb36C90cuc9OZzr3DpbjG1aFHny+hKTmXE+u+nM/Rrz3KGV8gmEEideIWaBKyhpTa
	AxmzMLAkJHnt6XhocYI1wt2AuDvncAQen4c+glreBhNvubGr+BuPgzWC3YKlJFSfPUg==
X-Received: by 2002:a63:1b11:: with SMTP id b17mr320115pgb.207.1556225307439;
        Thu, 25 Apr 2019 13:48:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztGNtgyzSWwDFE8yCuo6KCMu7y/QydLt0832nre8LrEkvgluaPeuo47CI2NQoDacA1KUeE
X-Received: by 2002:a63:1b11:: with SMTP id b17mr320067pgb.207.1556225306638;
        Thu, 25 Apr 2019 13:48:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556225306; cv=none;
        d=google.com; s=arc-20160816;
        b=JpsQmI/p3TyjICdk6NP/n0cFX4zY7zUscvTBCZ76dR0qpJyvq57gq4Y6h+Mp9bHAMY
         7XR+zhhG34c5AvqWJMwiP/02QLYDOaWM1aCttHlKI8Gq/YSNwVf4hoP7VdkqpobWzvm5
         nxnByFu/ZCTGVKl5h0hx1MD7VTV2H7yO93fEyAF0QesgeOXCTzOj6emy+lNN3ea0EgtR
         LhrYeOW2wq2IG5hM8fEDxSzY+PSOf1W+QcrZMDJN+oMoM7FG86hut4+fZ3utxpV5acKX
         Pamoca6zKavMZX1TjmKBf7iGSAsghzLxXuwJup3fyH7ZXz/nZEIZUNSmhWUX/+q9yte7
         j1qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FitD4X1vPtPf9AaJyZflnefh5ZXat3I/abaTtFAMS7o=;
        b=D/jFgtcQtn4669sZ43tKka57qHZ89Kgd8piSRGBAQYOwUB3HJpeabtATvmkXmRFNKo
         j7UWrw08IgZeuclAWekmz082yAatMytjj0x/sESnU6ucg2CjZAZclifidIcn7jIAS7TY
         xOkE0QThPRNLJtcUu6PvjX9uSMgkVyq0jLCU7Y7AbKf6QOyZiJmFrBrUBCFbIduuB8jg
         XxZ6M4mNHmI96rI0R4tIQ5TcYkm/mjy/m3teFre1rUw7G3zo4Gn2Ibk4pdN39EVNmMD4
         gqhZhdHT2zBVT/YzArMmkfaT+8+eSoAXz8O9wmOb33vHbL3OLbKPS9ylb644ip5LrsoG
         4bHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=i7Hq0H2F;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h3si5279340pgg.83.2019.04.25.13.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 13:48:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=i7Hq0H2F;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=FitD4X1vPtPf9AaJyZflnefh5ZXat3I/abaTtFAMS7o=; b=i7Hq0H2F0STZhj0SbYPU9kQNf
	yXzbfggcqkI1DmqjyE4zkvAQBey/AeHaQSKy5gSbwKkLTwv/FT04TvnIrvxoYqSNGJVJJWdMtTTQQ
	ZcfCSB6ucpcUXEcRxhfmRXEXntN3RoWa5wUxEQv1+JmF9Qy8PHR9FBVHKLLhTrA5p3yZQtkolmkVW
	ZIlhF1hrp9QUzLO1OIox4w7fuAzYgpy60cawbqqe9L3Dq3cQeVsABBJkHqSY1z8O86LBog6oknxGO
	JsbvmCIIwxF8uUxIR5t3ckfNmiE6XKhttFT2UJgruUV9acrrrYFEm3mAYeaPIBKlCrhCvxF5bTduV
	Ne8RFT5Tg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJlI6-0001R8-2x; Thu, 25 Apr 2019 20:48:22 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 6AB02203C0A58; Thu, 25 Apr 2019 22:48:20 +0200 (CEST)
Date: Thu, 25 Apr 2019 22:48:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com
Subject: Re: [PATCH v4 00/23] Merge text_poke fixes and executable lockdowns
Message-ID: <20190425204820.GB12232@hirez.programming.kicks-ass.net>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 11:57:42AM -0700, Rick Edgecombe wrote:
> Andy Lutomirski (1):
>   x86/mm: Introduce temporary mm structs
> 
> Nadav Amit (15):
>   Fix "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"
>   x86/jump_label: Use text_poke_early() during early init
>   x86/mm: Save DRs when loading a temporary mm
>   fork: Provide a function for copying init_mm
>   x86/alternative: Initialize temporary mm for patching
>   x86/alternative: Use temporary mm for text poking
>   x86/kgdb: Avoid redundant comparison of patched code
>   x86/ftrace: Set trampoline pages as executable
>   x86/kprobes: Set instruction page as executable
>   x86/module: Avoid breaking W^X while loading modules
>   x86/jump-label: Remove support for custom poker
>   x86/alternative: Remove the return value of text_poke_*()
>   x86/alternative: Comment about module removal races
>   tlb: provide default nmi_uaccess_okay()
>   bpf: Fail bpf_probe_write_user() while mm is switched
> 
> Rick Edgecombe (7):
>   x86/mm/cpa: Add set_direct_map_ functions
>   mm: Make hibernate handle unmapped pages
>   vmalloc: Add flag for free of special permsissions
>   modules: Use vmalloc special flag
>   bpf: Use vmalloc special flag
>   x86/ftrace: Use vmalloc special flag
>   x86/kprobes: Use vmalloc special flag

This all looks good to me, I'll queue them tomorrow when I'm awake
again. I'll move the last two patches to early in the series, since it
appears to me they're fixes and should be in place before we make the
situation worse with the temporary mm swizzling for text_poke.

If you want to post a new version of patch 4 before then, that'd be
awesome, otherwise I'll see if I can do those few edits myself.

