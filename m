Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B42FC76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 04:46:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C3FF22BE8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 04:46:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C3FF22BE8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E2596B0003; Fri, 26 Jul 2019 00:46:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 992B96B0005; Fri, 26 Jul 2019 00:46:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A94A8E0002; Fri, 26 Jul 2019 00:46:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB0B6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 00:46:40 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so33338400edm.21
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 21:46:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=Ri6wlOnch1WPhV3mOLcgEx84FUkukyATKfpwmt/wtBw=;
        b=Xj6f9+pLMTBJNixqjxzPsiz4W4b/EPdSZ+NNXK1c6g93fG2BrRoqgPNZZ73heFQXUq
         vUZX28KjO2mBBgrznk5KqyJFfYdJKSVa5sxgyp8H7fY2K4Xkm581E4iX6p44I1E20kTW
         zpN5xbE3vS7DEvySeDZJKbiwUGh1D/669Ke1oY1GLiGMjqUpUc+dlWq48KRwTxh2df3J
         uen38p/63Ed9yKEIWWE9tgKqC4VeEnoZunRlXBJT2iPe1XPCAmRmd6e+TWFjGMmsAvDY
         Ld11Aw/me9PiiHlHuKi44pKPxnLm7LYTuHuKqlFGCZ6nVucLR+1RsC2In7uofH1J+KIs
         e7DQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAV9BBWGBOExR/smqilmg8DDU0fZRyeaNd3EqCHWedfWQnX3Ty9i
	I4qO6PxsP8oWtc1zhk3ws2I2sjmONv8HGSRh+XF+WGmTxQxodlweorrpvfi+pthZgkJARl6JUKx
	P7vEoAhrc6MHQSYlpY9fR0YvifJsYS/gv0l9ps8vhWr87nkk+xOtGSVw5Q5rzGatyqQ==
X-Received: by 2002:a17:906:114d:: with SMTP id i13mr71033947eja.252.1564116399812;
        Thu, 25 Jul 2019 21:46:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEyz46FkaSh1KBDob6YLPGRvfDfSfa24pWlY0IJjIhhm34jiq9yQyfNo1d6p8LM47gLaQZ
X-Received: by 2002:a17:906:114d:: with SMTP id i13mr71033916eja.252.1564116399076;
        Thu, 25 Jul 2019 21:46:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564116399; cv=none;
        d=google.com; s=arc-20160816;
        b=kzPEpiRxcYgmZNi9NMKIAljqmK2uivAzKY8mRxwgoOfXdNXiWKbC0cjoaT7hmXhXKl
         XHhcsXC/LusmNA7YYI0BqzfPQNP98+93hiWS6eNBdt7b7aSyTPSmTRXC11YZ02rR7FvB
         9jE3d52OkJ/dxagNogMdfwbWmNVJpKl2nZJ23O63BXQV+cHhvzs6RFhotojoz1JHlqrs
         pW8sfWLJrRyv0Eh+jB4Sxi+5MaYcXrSkyFvbf4cRw92qkQIUVUAKIohEFnNyRfncLqH+
         pouViVAZo2H86gb6cM02BsC7kt33CwVWVGVqi3/0Bzbji6BU0AaJ1oXmHS3bOxenmrto
         XZZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=Ri6wlOnch1WPhV3mOLcgEx84FUkukyATKfpwmt/wtBw=;
        b=nDg0LUvqn1SIQDAfMJXYG8i840DhaCtTzkYb/PwHqnPhdqgwJH2AiD6AvxptK0DkGP
         Hy3ml4rGg2r9OkwG8BbM9QRmPCsVsBoYa+IfD6HVCwet5A0oQeXdk8Okj7yxmArIJdT8
         MDNo5Jq/WsJKFEZlfpTfozuxVBrtlKz1drZASte+Uw2OaHKyHSseRTwgsEOkGHcsmwvi
         8KmNMhvES8uxWbgrrCOzbIMoNTFXlvsch9BOrT0p71LWEW7mh7NKEOyeQF7/fq60PByI
         +OTbCtaFqhGXDDMHrMxeVw9q5OTAMd8bYS6nnOG3NBDjbR2X+P+55Sq8yBJmJjM20cO+
         PGsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e12si11477027edv.154.2019.07.25.21.46.38
        for <linux-mm@kvack.org>;
        Thu, 25 Jul 2019 21:46:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B6593337;
	Thu, 25 Jul 2019 21:46:37 -0700 (PDT)
Received: from [10.163.1.197] (unknown [10.163.1.197])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4CBE13F694;
	Thu, 25 Jul 2019 21:46:33 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Mark Brown <Mark.Brown@arm.com>, Steven Price <Steven.Price@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kees Cook <keescook@chromium.org>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Dave Hansen <dave.hansen@intel.com>, linux-arm-kernel@lists.infradead.org,
 x86@kernel.org, linux-kernel@vger.kernel.org
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
 <20190725143920.GW363@bombadil.infradead.org>
Message-ID: <c3bb0420-584c-de3b-2439-8702bc09595e@arm.com>
Date: Fri, 26 Jul 2019 10:17:11 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190725143920.GW363@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/25/2019 08:09 PM, Matthew Wilcox wrote:
> On Thu, Jul 25, 2019 at 12:25:23PM +0530, Anshuman Khandual wrote:
>> This adds a test module which will validate architecture page table helpers
>> and accessors regarding compliance with generic MM semantics expectations.
>> This will help various architectures in validating changes to the existing
>> page table helpers or addition of new ones.
> 
> I think this is a really good idea.
> 
>>  lib/Kconfig.debug       |  14 +++
>>  lib/Makefile            |   1 +
>>  lib/test_arch_pgtable.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++
> 
> Is this the right place for it?  I worry that lib/ is going to get overloaded
> with test code, and this feels more like mm/ test code.

Sure this can be moved to mm/ but unlike existing test configs there (following)
lets keep some config description in mm/Kconfig. Will probably rename this as
CONFIG_DEBUG_ARCH_PGTABLE_TEST to match other tests.

CONFIG_DEBUG_KMEMLEAK_TEST
CONFIG_DEBUG_RODATA_TEST
CONFIG_MEMTEST

After moving to mm/ directory I guess it does not need a loadable module option.

> 
>> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE
>> +static void pmd_basic_tests(void)
>> +{
>> +	pmd_t pmd;
>> +
>> +	pmd = mk_pmd(page, prot);
> 
> But 'page' isn't necessarily PMD-aligned.  I don't think we can rely on
> architectures doing the right thing if asked to make a PMD for a randomly
> aligned page.
> 
> How about finding the physical address of something like kernel_init(),

Physical address corresponding to the symbol in the kernel text segment ?

> and using the corresponding pte/pmd/pud/p4d/pgd that encompasses that

So I guess this will help us use pte/pmd/pud/p4d/pgd entries from a real and
present mapping rather then making them up for test purpose. Although we are
not creating real page tables here just wondering if this could some how
affect these real mapping in anyway from some accessors. The current proposal
stays clear from anything real - allocates, evaluates and releases.

Also table entries at pmd/pud/p4d/pgd cannot be operated with accessors in the
test. THP and PUD THP will operate on leaf entries at pmd or pud levels. We need
them as leaf entries created from allocated (aligned) pfns. While determining
pte/pmd/pud/p4d/pgd for kernel_init() some of them will be table entries.

> address?  It's also better to pass in the pfn/page rather than using global
> variables to communicate to the test functions.

Sure those can be allocated and passed from the main function. Just wanted to
avoid page allocation in each individual tests.

> 
>> +	/*
>> +	 * A huge page does not point to next level page table
>> +	 * entry. Hence this must qualify as pmd_bad().
>> +	 */
>> +	WARN_ON(!pmd_bad(pmd_mkhuge(pmd)));
> 
> I didn't know that rule.  This is helpful because it gives us somewhere
> to document all these tricksy little rules.

That is another objective this test has which will help settle semantics
in a clear and documented manner.

> 
>> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
>> +static void pud_basic_tests(void)
> 
> Is this the right ifdef?

IIUC THP at PUD is where the pud_t entries are directly operated upon and the
corresponding accessors are present only when HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
is enabled. Am I missing something here ?

