Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F759C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:41:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 173CC218C3
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:41:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 173CC218C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCC8B8E00DD; Wed,  6 Feb 2019 12:41:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7C218E00D9; Wed,  6 Feb 2019 12:41:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A92388E00DD; Wed,  6 Feb 2019 12:41:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6879D8E00D9
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 12:41:14 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id o7so5709341pfi.23
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 09:41:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=z9XFeucax8xYFihnspCDvcXkCu2137EDgTjxZuGxip8=;
        b=naXaawaJwaOG5aiA+oUcxDxTN09JMz7bbRT6EzkEQJ8aoaR0OGH0deSxAFgz5oavxa
         qODY6pnxdeYL2W54PQFqJlUSbZUMjQGCNV5yjLS4x2DPclLlCSejQmy7jJSDyHYfQOAX
         u7OUdsr1ofw5RRAGD3UyLUk2baBfznAwejPBti9AdhSg01PnVR0/ZMfrE19yXGf4ayQU
         RkL71QErblTBf7DAlT4vbxmrdn0pbeuEUgoUdNbpCv+tJjhcd3AXl/zmv2uei2LVWFjW
         gslmVRLq8ZjOUE6z8IsmCW0vtTcZug5+ZsgBn0irN+NXWj5Xih64Fa2xFr3B1u6pmhat
         sArQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=f26Y=QN=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: AHQUAuYnx2+LQSeG/rBdM0UxaOMGsBJhEoUGW7Em7qYxgzTj4iZnGzi1
	xzccAMOsnSfGe16mmZhkkonUbALkEzuIdYH1DHsvl4qc5Zh1X+aZDseeyGQAgEq9P0VkEFhaghx
	w1x4n8o/wA/C9mSKw4XUo0NDBxpms0ZIlx0SgW90ehLyVG3ZFlJMdhjLmgeVrJLo=
X-Received: by 2002:a63:e74b:: with SMTP id j11mr10645047pgk.397.1549474874077;
        Wed, 06 Feb 2019 09:41:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IazNhQGGeqA4hy/KbHOgkw/ujZoAuogylz3tq/FCuUMLqA4T2BA8d/lh43LZKqQSRFwiVaD
X-Received: by 2002:a63:e74b:: with SMTP id j11mr10645000pgk.397.1549474873396;
        Wed, 06 Feb 2019 09:41:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549474873; cv=none;
        d=google.com; s=arc-20160816;
        b=pr51sxblQj/kC7mQHxxs4huZFUaPzZMEwtB16USZqZZbuIAHtqCtE/RLVJCzWAcliD
         l71VDLzoW10r2LWaXlALdFt7xNkvvumlr5hLM6Dhh67dY62qx1+a+qopF7wxBScCloVu
         nQ7xvTs5BWdwe0D6vw/pwaxvJS8F4/vpE7qZQdrzdeFActQZLgrEBL27zrwJCmI8RV0d
         yD4S3C6OWdBjHKts8v3yPKJ+exzsvwUwS7rgrbaOl7wPIKCBfesigEBHohOHYQAIpXxv
         ObEAe9J6VyyE60U2m4ZBYqJi8vUaAHe2BIseGpa8kPOP5w7TdR35FJDUvjvZQYJwNiUD
         2h2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=z9XFeucax8xYFihnspCDvcXkCu2137EDgTjxZuGxip8=;
        b=T1etrHdbE2pjilogc/kycYEhtjwgi7OO7kZe3CtxYDNKcZNBKpr9g9pGTQR0cOqGO5
         bZoKovNZiaMU3mI3WPuAmNAU8uaC3dx8xYoy8k+QoCKqL7OFQkZiGuVNVFO+ObQ5zefm
         WJeJKWWW5DeZygPpSs16vj5Jv2Jw42R38JfOH+2txP/j46SnJoNxprMSZwbo/pNcvtpf
         UNNZSvLKokE5g6MO/XGvqRSiDx+CPPdhl8XrjOoRN2UXscQypHxJlB+hsd3wY0dkhP8m
         RVz+MbEIibZ8YqEwwq4PIN8kq2sVdtm/Z09c9AOaER7ZqylsT75gjNL2v4AYVB0Y31is
         HIGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=f26Y=QN=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w83si6592015pfk.125.2019.02.06.09.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 09:41:13 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=f26Y=QN=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4175C20B1F;
	Wed,  6 Feb 2019 17:41:11 +0000 (UTC)
Date: Wed, 6 Feb 2019 12:41:08 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Andy Lutomirski
 <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, LKML
 <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin"
 <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov
 <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra
 <peterz@infradead.org>, Damian Tometzki <linux_dti@icloud.com>,
 linux-integrity <linux-integrity@vger.kernel.org>, LSM List
 <linux-security-module@vger.kernel.org>, Andrew Morton
 <akpm@linux-foundation.org>, Kernel Hardening
 <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, Will
 Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Kristen Carlson Accardi <kristen@linux.intel.com>, deneen.t.dock@intel.com
Subject: Re: [PATCH 08/17] x86/ftrace: set trampoline pages as executable
Message-ID: <20190206124108.07eef568@gandalf.local.home>
In-Reply-To: <5DFA1E3C-A335-4C4B-A86F-904A6CF6D871@gmail.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
	<20190117003259.23141-9-rick.p.edgecombe@intel.com>
	<20190206112213.2ec9dd5c@gandalf.local.home>
	<5DFA1E3C-A335-4C4B-A86F-904A6CF6D871@gmail.com>
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2019 09:33:35 -0800
Nadav Amit <nadav.amit@gmail.com> wrote:


> >> 	/* Copy ftrace_caller onto the trampoline memory */
> >> 	ret = probe_kernel_read(trampoline, (void *)start_offset, size);
> >> @@ -818,6 +820,13 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
> >> 	/* ALLOC_TRAMP flags lets us know we created it */
> >> 	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
> >> 
> >> +	/*
> >> +	 * Module allocation needs to be completed by making the page
> >> +	 * executable. The page is still writable, which is a security hazard,
> >> +	 * but anyhow ftrace breaks W^X completely.
> >> +	 */  
> > 
> > Perhaps we should set the page to non writable after the page is
> > updated? And set it to writable only when we need to update it.  
> 
> You remember that I sent you a patch that changed all these writes into
> text_poke() and you said that I should defer it until this series is merged?
> 

And I notice that it is set to RO after this call anyway.

-- Steve

