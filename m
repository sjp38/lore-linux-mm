Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06CA7C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:50:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAAA1208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:50:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAAA1208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 494576B027E; Mon, 13 May 2019 11:50:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41D806B027F; Mon, 13 May 2019 11:50:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BEB26B0280; Mon, 13 May 2019 11:50:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E45C06B027E
	for <linux-mm@kvack.org>; Mon, 13 May 2019 11:50:23 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e14so9413684pgg.12
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:50:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=sTJjjFBRC+akyjpIg3/YuAAV2c0/g+ldpxky+XG32/w=;
        b=Cog0igpTGWklr/8SHY49gr63vsBtdEX3kXNu0FZn2dJinwAYaBnVhLR74mRJTF7w/T
         0lFTvONuALtAcaJcibGHzx83JR/ExY1A7W3IohYRj5mSuuKgpEVB8mI1sm20FN6UlNON
         qYq4KrfeiYsq6BqPf5AHuR1WNEM/aNGEYHdoYacOUck0NwAyBhNqXBlwEJxbnI2nOgb4
         4dGhsiclkfKPNS2i9TxHkKvJLYSRxgPHOTwmGLfq6reayuwgf/PmLmMyqTE32QWBRTWv
         jtJ/4G08T/yHDUy1+/YOQsPOY/k+LGgQnrB+oevaxW12QgHR0Whtpc+yQd2HY1ToPhPn
         umCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUWFn7lsAG6uUUUR/9MnoOoUrcX/UxZhw+WwvwnHaev4AK5RhmW
	Ih1IzDrQurg7CFSsMOJrcp1w+ZbQgLavFS6gZk8BHNTuSFMn7TAvodvQXkGlL0MdtjTgmKwxtkQ
	4zde9pi/wQsSCIR0zmAwmKEWZ+O129OqdnQwdEwV9y5nwJuayNGDEN2fgOtOddcK6eg==
X-Received: by 2002:a63:7d09:: with SMTP id y9mr11812282pgc.350.1557762623447;
        Mon, 13 May 2019 08:50:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1K+NH8ass42Ki9FE16upbrKPXaLkckkGkoH9AeLZIpH65Vm/XWMiH13NX47F98qUQzEUS
X-Received: by 2002:a63:7d09:: with SMTP id y9mr11812182pgc.350.1557762622555;
        Mon, 13 May 2019 08:50:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557762622; cv=none;
        d=google.com; s=arc-20160816;
        b=AJC615SI9hWWAfTWQ1QoRxub3ghUksPSdc76fVTJjeY0B/dOpgz4Rf1E9OQji6Qb0u
         whkU81LE16pYE8yh6AWQwm1ERI6UBfxxtUw1Rn3XISyg9c2UhWUJM6PK4+s3MII4vAyG
         eGk8Jmg6UE8M+WSZZ4iRqNbfock0A4B018QmlURHqqCtUfh2ap2jJeuWMkO6Q9VOUwLW
         qwqAQFNmz7EMHjBC9FqljIUmZ/mdqlcAsXlm1Br66W+P+HpxbQdN+/cfqIbeIrFjRtAA
         oJMudCHE+7qCikcH+OqKj9L8tbqx5GiV2muaSi4RO19EozAGW+jCJa3std2gY/sGKmvC
         C1BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=sTJjjFBRC+akyjpIg3/YuAAV2c0/g+ldpxky+XG32/w=;
        b=Fr5qV0kCqSDPFX23u6vuVzX5x4lyl9ddvwrnzI2MS6JkJUU1riEfzJnohk/3wmUlAx
         ZBlQze0ZU29bwNLRcuJAU/nQqQDKANlhmltudyhXLUYiRGxKaiXYURLMw/sSv3tdGSsQ
         2fclHmHDp0eKEsc/U3L/+D5OfD8TqLSK/ifO39alMb4rDWSQSG4+lhQ9q3z0JxzmHKZ/
         sBqINirNogEZAZA8UEEab+L8M3KIMBmUMdoJ1px1iji7U+j9s7UTOMQToXON19oxMUr6
         c5GDfWQCQ2BU4fR2uRuEM/HB5zN6itMCLaTuUyl/vaW+83xUJaWHZrJ3/WAsRgp6XieX
         4Uvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u9si17016571pls.145.2019.05.13.08.50.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 08:50:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 May 2019 08:50:22 -0700
X-ExtLoop1: 1
Received: from nsmith1-mobl.amr.corp.intel.com (HELO [10.251.15.98]) ([10.251.15.98])
  by orsmga003.jf.intel.com with ESMTP; 13 May 2019 08:50:20 -0700
Subject: Re: [RFC KVM 19/27] kvm/isolation: initialize the KVM page table with
 core mappings
To: Alexandre Chartre <alexandre.chartre@oracle.com>, pbonzini@redhat.com,
 rkrcmar@redhat.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
 hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
 peterz@infradead.org, kvm@vger.kernel.org, x86@kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
 liran.alon@oracle.com, jwadams@google.com
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-20-git-send-email-alexandre.chartre@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <a9198e28-abe1-b980-597e-2d82273a2c17@intel.com>
Date: Mon, 13 May 2019 08:50:19 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1557758315-12667-20-git-send-email-alexandre.chartre@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +	/*
> +	 * Copy the mapping for all the kernel text. We copy at the PMD
> +	 * level since the PUD is shared with the module mapping space.
> +	 */
> +	rv = kvm_copy_mapping((void *)__START_KERNEL_map, KERNEL_IMAGE_SIZE,
> +	     PGT_LEVEL_PMD);
> +	if (rv)
> +		goto out_uninit_page_table;

Could you double-check this?  We (I) have had some repeated confusion
with the PTI code and kernel text vs. kernel data vs. __init.
KERNEL_IMAGE_SIZE looks to be 512MB which is quite a bit bigger than
kernel text.

> +	/*
> +	 * Copy the mapping for cpu_entry_area and %esp fixup stacks
> +	 * (this is based on the PTI userland address space, but probably
> +	 * not needed because the KVM address space is not directly
> +	 * enterered from userspace). They can both be copied at the P4D
> +	 * level since they each have a dedicated P4D entry.
> +	 */
> +	rv = kvm_copy_mapping((void *)CPU_ENTRY_AREA_PER_CPU, P4D_SIZE,
> +	     PGT_LEVEL_P4D);
> +	if (rv)
> +		goto out_uninit_page_table;

cpu_entry_area is used for more than just entry from userspace.  The gdt
mapping, for instance, is needed everywhere.  You might want to go look
at 'struct cpu_entry_area' in some more detail.

> +#ifdef CONFIG_X86_ESPFIX64
> +	rv = kvm_copy_mapping((void *)ESPFIX_BASE_ADDR, P4D_SIZE,
> +	     PGT_LEVEL_P4D);
> +	if (rv)
> +		goto out_uninit_page_table;
> +#endif

Why are these mappings *needed*?  I thought we only actually used these
fixup stacks for some crazy iret-to-userspace handling.  We're certainly
not doing that from KVM context.

Am I forgetting something?

> +#ifdef CONFIG_VMAP_STACK
> +	/*
> +	 * Interrupt stacks are vmap'ed with guard pages, so we need to
> +	 * copy mappings.
> +	 */
> +	for_each_possible_cpu(cpu) {
> +		stack = per_cpu(hardirq_stack_ptr, cpu);
> +		pr_debug("IRQ Stack %px\n", stack);
> +		if (!stack)
> +			continue;
> +		rv = kvm_copy_ptes(stack - IRQ_STACK_SIZE, IRQ_STACK_SIZE);
> +		if (rv)
> +			goto out_uninit_page_table;
> +	}
> +
> +#endif

I seem to remember that the KVM VMENTRY/VMEXIT context is very special.
 Interrupts (and even NMIs?) are disabled.  Would it be feasible to do
the switching in there so that we never even *get* interrupts in the KVM
context?

I also share Peter's concerns about letting modules do this.  If we ever
go down this road, we're going to have to think very carefully how we
let KVM do this without giving all the not-so-nice out-of-tree modules
the keys to the castle.

A high-level comment: it looks like this is "working", but has probably
erred on the side of mapping too much.  The hard part is paring this
back to a truly minimal set of mappings.

