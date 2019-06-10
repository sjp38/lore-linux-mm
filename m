Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A455C468C3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:34:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E385C20820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:34:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E385C20820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 612B26B0003; Mon, 10 Jun 2019 00:34:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C35B6B0006; Mon, 10 Jun 2019 00:34:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48AAD6B0007; Mon, 10 Jun 2019 00:34:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F03266B0003
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 00:34:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b3so12453947edd.22
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 21:34:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=vnZZCsfdq27GlhZOtK3ksuxOjCUAUL64xQDV+y6tmvw=;
        b=bnX/Pl2cLpKuk9lKf34XOkKU6WgeGtLXtR+DQ40PaxvUVSO8ELsWp+cQ3/b0N6NeHb
         vLoTP1zB2G8aRorupkDHDYUQN/prhKoOG6qQEcJ21A26BWzOvWHkCHE+BNEBHPqtGI5Q
         eomLPo6vTlrYtYlo7JWGL6guU8wegpeydPxJ7tK3JqsJmDzQ9XWnaQW6Q43lmGJVCohI
         8XRUthHiBK1TrcG1+XV9kH86eVQaOusDVm1CkxPpYUKUC0k3Thdd/cmWQZH0TfAxZsPl
         utFTP4NvwpGRQexCNNpNwYUoNrTvUQGAQHeSEsEIuH3eTefEDzjt2tLc9rZpwfm60c4L
         NBuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUV4KaFNHNBzP+K99VvXastgYa0VwOcEuf/lcl71F+9Q8op3pd4
	5V28F065A7eEqCD1ao666dYdQhf7CeOlfFu9MBgq/HcVizbYBMcd/gQJBRbkoLAuDnGeW3P+sZJ
	0Em+sGga5iYzw9AAhgQyTA6drfMZYgrpP3FmCeyVvVNPkPSqqXi5h236LNuK+oWQbfw==
X-Received: by 2002:a17:906:25c9:: with SMTP id n9mr36427486ejb.51.1560141285498;
        Sun, 09 Jun 2019 21:34:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypKXgoJlK6r5pFBkGx5v6RfJC0cqHg9vTkrLmtL5S2OXOOeh3cHzLf+vXZZTT5H9SDgwlv
X-Received: by 2002:a17:906:25c9:: with SMTP id n9mr36427442ejb.51.1560141284542;
        Sun, 09 Jun 2019 21:34:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560141284; cv=none;
        d=google.com; s=arc-20160816;
        b=CwChA8+EAj7qzWOZP70U7Q4IKOI+bbFSijwwR6E6QeZ9QZjvRwu4udXLEefPxxX24c
         yJNL0la1RpLG8KUwOoBrAWi8wS9rE7cA64ynwzdrTbULfazZ9X/wVsJpoMult/Cxo0S2
         MGS97Xq/O72SbSKKpr/OmoTDheIUlzGmQ/ALI/pyJeoSSARo4k4M4knwDYKmfDp66mAI
         E0LIYSF9NAbwx8dzPx81VR0GeYs//n30HkGz0fRjPrOSp4/MTDXiqeXh2E+Ta+FANl5Q
         792t+PoJ8Q+mdCLholYbKItXO9YVseeueNRvGyBda84Kh607UYs7eJ30kwxhxlRwQAa0
         uXSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=vnZZCsfdq27GlhZOtK3ksuxOjCUAUL64xQDV+y6tmvw=;
        b=lfHRZ289te97zMDtdgM+qJonMi8gomkQJIPzw9P085zkE7LENkX6OMMiW4xqOtcWqv
         PEeHcLq7MZFmGJnp/9Slo0NvR8aJE8y83VB3S427OFZP+zTD3vxJpquSomd97x8NoTIS
         W3PpwrDYSL2+RcJTDMSqlohjkFA9GO68O1wjMFAyfaZeMsyz25xWj2+SeLLulswhLGIS
         geqUl/UC8D2zNfNSY5OmABo9XycBvviBfkLZUYNkJtDwDyDP0jcXtoqtYOKbbf3dDXqH
         HPErwb/mOxC50PmbPn8D0TfyTd927z72bmNjsZludidbSmnt1G53R5npUHFRmp+AF0fS
         DRuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g44si175002edg.58.2019.06.09.21.34.44
        for <linux-mm@kvack.org>;
        Sun, 09 Jun 2019 21:34:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 69043337;
	Sun,  9 Jun 2019 21:34:43 -0700 (PDT)
Received: from [10.162.42.131] (p8cg001049571a15.blr.arm.com [10.162.42.131])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B2CA33F557;
	Sun,  9 Jun 2019 21:34:31 -0700 (PDT)
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Andrey Konovalov <andreyknvl@google.com>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
 Dave Hansen <dave.hansen@linux.intel.com>, Vineet Gupta
 <vgupta@synopsys.com>, linux-snps-arc@lists.infradead.org,
 James Hogan <jhogan@kernel.org>, linux-mips@vger.kernel.org,
 Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
 <20190607201202.GA32656@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <f1b109a3-ef4c-359c-a124-e219e84a6266@arm.com>
Date: Mon, 10 Jun 2019 10:04:49 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190607201202.GA32656@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/08/2019 01:42 AM, Matthew Wilcox wrote:
> Before:
> 
>> @@ -46,23 +46,6 @@ kmmio_fault(struct pt_regs *regs, unsigned long addr)
>>  	return 0;
>>  }
>>  
>> -static nokprobe_inline int kprobes_fault(struct pt_regs *regs)
>> -{
>> -	if (!kprobes_built_in())
>> -		return 0;
>> -	if (user_mode(regs))
>> -		return 0;
>> -	/*
>> -	 * To be potentially processing a kprobe fault and to be allowed to call
>> -	 * kprobe_running(), we have to be non-preemptible.
>> -	 */
>> -	if (preemptible())
>> -		return 0;
>> -	if (!kprobe_running())
>> -		return 0;
>> -	return kprobe_fault_handler(regs, X86_TRAP_PF);
>> -}
> 
> After:
> 
>> +++ b/include/linux/kprobes.h
>> @@ -458,4 +458,20 @@ static inline bool is_kprobe_optinsn_slot(unsigned long addr)
>>  }
>>  #endif
>>  
>> +static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
>> +					      unsigned int trap)
>> +{
>> +	int ret = 0;
>> +
>> +	/*
>> +	 * To be potentially processing a kprobe fault and to be allowed
>> +	 * to call kprobe_running(), we have to be non-preemptible.
>> +	 */
>> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
>> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
>> +			ret = 1;
>> +	}
>> +	return ret;
>> +}
> 
> Do you really think this is easier to read?
> 
> Why not just move the x86 version to include/linux/kprobes.h, and replace
> the int with bool?

Will just return bool directly without an additional variable here as suggested
before. But for the conditional statement, I guess the proposed one here is more
compact than the x86 one.

> 
> On Fri, Jun 07, 2019 at 04:04:15PM +0530, Anshuman Khandual wrote:
>> Very similar definitions for notify_page_fault() are being used by multiple
>> architectures duplicating much of the same code. This attempts to unify all
>> of them into a generic implementation, rename it as kprobe_page_fault() and
>> then move it to a common header.
> 
> I think this description suffers from having been written for v1 of
> this patch.  It describes what you _did_, but it's not what this patch
> currently _is_.
> 
> Why not something like:
> 
> Architectures which support kprobes have very similar boilerplate around
> calling kprobe_fault_handler().  Use a helper function in kprobes.h to
> unify them, based on the x86 code.
> 
> This changes the behaviour for other architectures when preemption
> is enabled.  Previously, they would have disabled preemption while
> calling the kprobe handler.  However, preemption would be disabled
> if this fault was due to a kprobe, so we know the fault was not due
> to a kprobe handler and can simply return failure.  This behaviour was
> introduced in commit a980c0ef9f6d ("x86/kprobes: Refactor kprobes_fault()
> like kprobe_exceptions_notify()")

Will replace commit message with above.

> 
>>  arch/arm/mm/fault.c      | 24 +-----------------------
>>  arch/arm64/mm/fault.c    | 24 +-----------------------
>>  arch/ia64/mm/fault.c     | 24 +-----------------------
>>  arch/powerpc/mm/fault.c  | 23 ++---------------------
>>  arch/s390/mm/fault.c     | 16 +---------------
>>  arch/sh/mm/fault.c       | 18 ++----------------
>>  arch/sparc/mm/fault_64.c | 16 +---------------
>>  arch/x86/mm/fault.c      | 21 ++-------------------
>>  include/linux/kprobes.h  | 16 ++++++++++++++++
> 
> What about arc and mips?

+ Vineet Gupta <vgupta@synopsys.com> 
+ linux-snps-arc@lists.infradead.org

+ James Hogan <jhogan@kernel.org>
+ Paul Burton <paul.burton@mips.com>
+ Ralf Baechle <ralf@linux-mips.org>
+ linux-mips@vger.kernel.org

Both the above architectures dont call kprobe_fault_handler() from the
page fault context (do_page_fault() to be specific). Though it gets called
from mips kprobe_exceptions_notify (DIE_PAGE_FAULT). Am I missing something
here ?

