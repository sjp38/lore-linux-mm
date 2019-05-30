Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C775C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:01:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB76A2589C
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:01:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB76A2589C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCA086B0010; Thu, 30 May 2019 08:01:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA1496B026B; Thu, 30 May 2019 08:01:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C908C6B026C; Thu, 30 May 2019 08:01:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA226B0010
	for <linux-mm@kvack.org>; Thu, 30 May 2019 08:01:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n23so8341089edv.9
        for <linux-mm@kvack.org>; Thu, 30 May 2019 05:01:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=MizdGkz8MMsgTNlvw4HRkezT9OnhyL5jwEgqk55HTI0=;
        b=WCMZvSLnRhCBBgxYVNVwCk36tnX6lxt0QdsbPhuyYFWf4XLJwJHfVMn9l5aG5SFQ14
         uCUPGX7cvrQM8kuG1L+tWIoWsim0LgU1bIxoNtoOuLNgpZpE8vNvawXBpA+HwuyXT3jb
         IjBdCTA3SLk3B5/99+ylp4ON+arAEMGw07ks9JE8CAKB9YihQmlErF+p10cYOqWLdKd5
         hKc3PqakOdDYi21FFSzSpYejQbHXE8jKhR5bWTxEnpBVdHoL+C9EZWqlRtBbFySnXSWX
         PrjJwP6GuyhRILbHiKC3DU23rr/YJ7/nzxkVzw6GsajwWvj1mAz2lcp+IDAyzwFElTik
         RdQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXZKTQZH91rgnuGZCDX06p+bxhniBjp6EaVAUGsvlL9I/ARRJtm
	keLahm92tnGHM41v0OE2RXZAgirC1JfnRqO5f+6d56KqKfGgRqv6oCfPxi6N/dIaakFTDf0JB6s
	njTR9c3Axk8+pEO7Iow7BCg9L6z8hBTlV3a5Vq7K8ziWgXACF2E0ju0EvpklnKhOQNw==
X-Received: by 2002:a17:906:6ad8:: with SMTP id q24mr3073896ejs.94.1559217672982;
        Thu, 30 May 2019 05:01:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKX5NoGlEbzoM2ADy0kDp5EOQL+wF1E0Lx0iTFE+D1/VjpF+vnDmkyoxQFfCRXxT6y2OZ+
X-Received: by 2002:a17:906:6ad8:: with SMTP id q24mr3073705ejs.94.1559217671276;
        Thu, 30 May 2019 05:01:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559217671; cv=none;
        d=google.com; s=arc-20160816;
        b=wFwQsNy1OaI4DbtMKvp70rASzVL89f99ifFeGCAd1t0odKsdI+eEQSrse8g8OjKzbk
         dICk5l34p9bFROV7QkAvaf6jHlp1f+qZPTmlhIEJP0LLFA/xo5qucwHn7+y44DHr5NKd
         WVVnY/NaPR0imuzzENSeD8UhZ3xf/Uj/SLvVh8n2WZBKtfpeeaxGCpo3fvvJyCXVfHX1
         wqpv4UGQKMLvDMoZ5fxspHmSJfX+bupY7PdLGdApTNxUUp4hqm2kvCmTS5Rzo+V0/Iux
         q3iIZDhAXSJ04uZWMwp5ASBeDi6G9GaAUsT0AM9Zl2VRFIPeKzZUhLrTo0r2Ij57T+hS
         Uy8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=MizdGkz8MMsgTNlvw4HRkezT9OnhyL5jwEgqk55HTI0=;
        b=XTSyyNzKjBERO5DTv4ZBj+dG8+2j5BiTLoaEn2QaCtXy3hGBNwu4nvWw1FdMMvUD+B
         gsAUy2xO7/TVHQi7JDTo++2ovp9YrVgFJt+7VV2lsjTr+UCVVyTftd2edWtkMdGoD62+
         9Zz9qnka01e+5fHiwWdWXqQxggvRev7lB+3wOBvNjlnfnyOBMv2nl23ZzIqmXoXJ/4gb
         9m8XGU1zNR2iugrgcVXUyJz7SNQrh5woItYAmbfP3mlz8Ijw8wL+LLdk0p0Efgl33CCY
         D7LKrVlbRKgJtei3SRvl9l5W0zXZyGikGMTQbVYAezrZzBaTRbAwRydjKAU/n2N9ibyH
         3EmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b14si508452ejk.227.2019.05.30.05.01.10
        for <linux-mm@kvack.org>;
        Thu, 30 May 2019 05:01:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A3F10374;
	Thu, 30 May 2019 05:01:09 -0700 (PDT)
Received: from [10.162.40.143] (p8cg001049571a15.blr.arm.com [10.162.40.143])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B2F953F5AF;
	Thu, 30 May 2019 05:01:02 -0700 (PDT)
Subject: Re: [RFC] mm: Generalize notify_page_fault()
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
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
 "David S. Miller" <davem@davemloft.net>
References: <1559195713-6956-1-git-send-email-anshuman.khandual@arm.com>
 <20190530110639.GC23461@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <4f9a610d-e856-60f6-4467-09e9c3836771@arm.com>
Date: Thu, 30 May 2019 17:31:15 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190530110639.GC23461@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/30/2019 04:36 PM, Matthew Wilcox wrote:
> On Thu, May 30, 2019 at 11:25:13AM +0530, Anshuman Khandual wrote:
>> Similar notify_page_fault() definitions are being used by architectures
>> duplicating much of the same code. This attempts to unify them into a
>> single implementation, generalize it and then move it to a common place.
>> kprobes_built_in() can detect CONFIG_KPROBES, hence notify_page_fault()
>> must not be wrapped again within CONFIG_KPROBES. Trap number argument can
> 
> This is a funny quirk of the English language.  "must not" means "is not
> allowed to be", not "does not have to be".

You are right. Noted for future. Thanks !

> 
>> @@ -141,6 +142,19 @@ static int __init init_zero_pfn(void)
>>  core_initcall(init_zero_pfn);
>>  
>>  
>> +int __kprobes notify_page_fault(struct pt_regs *regs, unsigned int trap)
>> +{
>> +	int ret = 0;
>> +
>> +	if (kprobes_built_in() && !user_mode(regs)) {
>> +		preempt_disable();
>> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
>> +			ret = 1;
>> +		preempt_enable();
>> +	}
>> +	return ret;
>> +}
>> +
>>  #if defined(SPLIT_RSS_COUNTING)
> 
> Comparing this to the canonical implementation (ie x86), it looks similar.
> 
> static nokprobe_inline int kprobes_fault(struct pt_regs *regs)
> {
>         if (!kprobes_built_in())
>                 return 0;
>         if (user_mode(regs))
>                 return 0;
>         /*
>          * To be potentially processing a kprobe fault and to be allowed to call
>          * kprobe_running(), we have to be non-preemptible.
>          */
>         if (preemptible())
>                 return 0;
>         if (!kprobe_running())
>                 return 0;
>         return kprobe_fault_handler(regs, X86_TRAP_PF);
> }
> 
> The two handle preemption differently.  Why is x86 wrong and this one
> correct?

Here it expects context to be already non-preemptible where as the proposed
generic function makes it non-preemptible with a preempt_[disable|enable]()
pair for the required code section, irrespective of it's present state. Is
not this better ?

