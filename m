Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0B9EC7618E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 11:32:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64F5C206B8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 11:32:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64F5C206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E31868E0003; Mon, 29 Jul 2019 07:32:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE2AC8E0002; Mon, 29 Jul 2019 07:32:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD1008E0003; Mon, 29 Jul 2019 07:32:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF6A8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:32:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y3so38059706edm.21
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:32:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WopCjjspgIawBvVbPd70+X5gbjHpqmrzPaq1C0u4lO8=;
        b=i3ceoCjGYTcbMOwaV3yRaYH+Ov1X9ucyPPxxVbpOowGRp0+nxHLeFTXGiP64/B+uV2
         GREqQsg+VEXl+4jLQ1+oG2fnNV3iA6TbRHXYBCceyYoAPoFUiKc6KMDs2P+sket4T73T
         eX4QNyyP36CB4/bPp3TXlnhqq7zDxQS2i7K8lCkmz52x9iuasF4YznTb06IJ08eHyyvF
         t+0O0yYMiCeZTXSZN++s5MkCxgQthBVIxaZqk03x4Z93NzUTw97CxX4iQIokSKCze/A3
         QeTk81IkJ1Kea+A+iVs1Tl7v+Eavnv3FnhnKlBSiweaYZHTesWKL1KBvLl00muvAIdeG
         dljw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXytS6JDPc1QJjIhKWsXRE8GWYJoczwoqr+u/mkS6KizIoCX7Xm
	6hgA72PSHE17QckZA/wbLrbS6VZQbpGf5taiaV1XtWaYLrSExgPeuEoI4lR+849D4W5fe/cg2DG
	c1oWYK6YQSGzEKKVN6wSlD7QXPEz8JgtvRuhoKLRaG9XYSmmXiFul/FLQdMcuSG+Kkw==
X-Received: by 2002:a50:9177:: with SMTP id f52mr95787934eda.294.1564399950964;
        Mon, 29 Jul 2019 04:32:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEx3M1zD8X084Cr2Zs/USavsQMnhOVkwuw1zfQ8ZjOSG+6jnpE0shW7tnWGzhyqt75+bIb
X-Received: by 2002:a50:9177:: with SMTP id f52mr95787844eda.294.1564399949976;
        Mon, 29 Jul 2019 04:32:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564399949; cv=none;
        d=google.com; s=arc-20160816;
        b=QoruLYn0rLYH4E2O2wDv4RkllubJHGQqFCpA9I4q1ScFJ6/w+LNZJP6cFk1B1FSOWk
         4veARZwxUjgExotxW7PhnSUasYOVd5oOeZfRNErTTN41FUAzH5bNOZQpB1J9eeb7Wd+T
         ab+bQURDx/wNJ0Ajtzb/MVkV1FEoHwV8P7S2vXzUeVI/0Ii/Of27uRd7T9NyvJOp8cey
         yAnlFj2jZYvFBDvUjzwq8SKeKe57cErToQb+C5RiTYGqo3Kwc9L2sS5MPY52hhIniWT8
         p5gG5hKpVXw9Tul8iM2aDuB5TdnYovd1z0EDfUFcznPQzSxtetug2WIZI/KKayIwy6oW
         sjbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WopCjjspgIawBvVbPd70+X5gbjHpqmrzPaq1C0u4lO8=;
        b=njdauGUiMNUm1ctxPX+i2WVAriLek8MvmNCxW6Ai9gAovasTLfb+Tww7JEA5B0F3Mx
         icsecm6tNt8xIkhsYzgv5DMt/bCT8kgDoXA9ioVed8EqZ5qCQrhkPWMVk23eRVS7JSky
         Iq1tAv8xOiykBHfEqvWym1qQhTsR48PPe+nskqIlqOJ+4MCgdYqyK+IWxAwIdz23gM1b
         TLuXfplQ22fGi5EzyAQ/d93He8EpnhLxDkAO2XiKpI4X4BaICbwaTUPEJwwPtEQ72yNk
         9Ywo0+wbCI0aSIZKR0wnQLA7Q1QZHld8YJpTxrc0yz5gIIUHRpW8fMWwGTD/MzHcX/q5
         77vQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 91si17307603edr.174.2019.07.29.04.32.29
        for <linux-mm@kvack.org>;
        Mon, 29 Jul 2019 04:32:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EF9BD28;
	Mon, 29 Jul 2019 04:32:28 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 609A73F694;
	Mon, 29 Jul 2019 04:32:26 -0700 (PDT)
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
 Helge Deller <deller@gmx.de>
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <794fb469-00c8-af10-92a8-cb7c0c83378b@arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <270ce719-49f9-7c61-8b25-bc9548a2f478@arm.com>
Date: Mon, 29 Jul 2019 12:32:25 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <794fb469-00c8-af10-92a8-cb7c0c83378b@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/07/2019 12:20, Anshuman Khandual wrote:
> On 07/22/2019 09:11 PM, Steven Price wrote:
>> Steven Price (21):
>>   arc: mm: Add p?d_leaf() definitions
>>   arm: mm: Add p?d_leaf() definitions
>>   arm64: mm: Add p?d_leaf() definitions
>>   mips: mm: Add p?d_leaf() definitions
>>   powerpc: mm: Add p?d_leaf() definitions
>>   riscv: mm: Add p?d_leaf() definitions
>>   s390: mm: Add p?d_leaf() definitions
>>   sparc: mm: Add p?d_leaf() definitions
>>   x86: mm: Add p?d_leaf() definitions
> 
> The set of architectures here is neither complete (e.g ia64, parisc missing)
> nor does it only include architectures which had previously enabled PTDUMP
> like arm, arm64, powerpc, s390 and x86. Is there any reason for this set of
> archs to be on the list and not the others which are currently falling back
> on generic p?d_leaf() defined later in the series ? Are the missing archs
> do not have huge page support in the MMU ? If there is a direct dependency
> for these symbols with CONFIG_HUGETLB_PAGE then it must be checked before
> falling back on the generic ones.

The list of architectures here is what I believe to be the list of
architectures which can have leaf entries further up the tree than
normal. I'm by no means an expert on all these architectures so I'm
hoping someone will chime in if they notice something amiss. Obviously
all the NO_MMU

ia64 as far as I can tell doesn't implement leaf entries further up - it
has an interesting hybrid hardware/software walk mechanism and as I
understand it the hardware never walks the page table tree that the
p?d_xxx() operations operate on. So this is a software implementation
detail - but the existance of p?d_huge functions which always return 0
were my first clue that leaf entries are only at the bottom of the tree.

parisc is more interesting and I'm not sure if this is necessarily
correct. I originally proposed a patch with the line "For parisc, we
don't support large pages, so add stubs returning 0" which got Acked by
Helge Deller. However going back to look at that again I see there was a
follow up thread[2] which possibly suggests I was wrong?

Can anyone shed some light on whether parisc does support leaf entries
of the page table tree at a higher than the normal depth?

[1] https://lkml.org/lkml/2019/2/27/572
[2] https://lkml.org/lkml/2019/3/5/610

The intention is that the page table walker would be available for all
architectures so that it can be used in any generic code - PTDUMP simply
seemed like a good place to start.

> Now that pmd_leaf() and pud_leaf() are getting used in walk_page_range() these
> functions need to be defined on all arch irrespective if they use PTDUMP or not
> or otherwise just define it for archs which need them now for sure i.e x86 and
> arm64 (which are moving to new generic PTDUMP framework). Other archs can
> implement these later.

The intention was to have valid definitions for all architectures, but
obviously I need help from those familiar with those other architectures
to check whether I've understood them correctly.

Thanks,

Steve

