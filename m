Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 893B3C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:23:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51EDA217D9
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:23:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51EDA217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD6D28E0004; Mon, 18 Feb 2019 12:23:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5F958E0002; Mon, 18 Feb 2019 12:23:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C28768E0004; Mon, 18 Feb 2019 12:23:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 644F38E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:23:32 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o9so904507edh.10
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:23:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1flPHUUAFedhAd2fMzIDDL+MwERnyOqY+Bv7YRR5bhA=;
        b=fd5oltJQVvmpNaWJHM8xRMSaq31VivY5cAWKpcrQduhLYPWDbiiEklLKhvGAAlw56s
         j0ZRRw57GBUfXhG5pDxz+RdRkzndpWcyKiw8OaxH4CWbj/UjJXeliKlvMO8QIuiBdc+G
         GlTnP9XYsebwoD1vGlvTC73XtusMudsEw3bAz79vAd9tn7j/Jyv9KgsdZF2rjYM15bQu
         PM/6/7HFVEseYPJk+eXSgKu9894ENHFpcM+kYiVnQzjdN6VOp+g7uiqE5SNVkvsfIFSL
         CS9bh/qKk9/WSowlnIbVsv+6Ge5bgJCRXd8bFMa1hoW9JNcUDhbI4DbJGrY5CEN7lm8V
         IjIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAub/SDcQeQ/ROdVKL/2XGqvNN7j7ClIxXL1apvK0lHr7CLAAw9gO
	2BxOMhHP3KHNmaKiKIqIILEP0+gHKMjKtpGFeaVERjxBitULos4G438sOudwsFqc5xWIU04erLB
	D4BPbQ7peV+QHPAH4W5pWF0ypbSNVgSVDzcnrtGTi9rTXYgRG19eF2zC5LfMZQtdJzg==
X-Received: by 2002:a17:906:bb08:: with SMTP id jz8mr16794519ejb.181.1550510611946;
        Mon, 18 Feb 2019 09:23:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYtDsyG18FTzwXr+YxTbVoHHaCEG1TL7rRSaqAKmalkcKSw22/bnO1dPoQq6LwZLssYyA2J
X-Received: by 2002:a17:906:bb08:: with SMTP id jz8mr16794469ejb.181.1550510610970;
        Mon, 18 Feb 2019 09:23:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550510610; cv=none;
        d=google.com; s=arc-20160816;
        b=gpNMts7Jv66bTJ0xn4qsG3Hu0VqQs8lNrYVHB2oh8KW6JNFkhiCVEiC0vG6K5+f/BE
         R6UUrcCVtBMl8QOywTWtxQQAfTko0KrDrh2UOwTtb/PmsrbTQfLEJQE2ms76/i6VU916
         NA/AlYNmvs8B8x0kzuC42Z8c99J/PF+oWe0G2VSBwoDvOX4Ew+7QyGpHN0q8Ui8x/5Ne
         I8PlXP2wC37Nqx1qpIFOpD15z3l5yFoBmGYN7/JZkKMEPZrQY90Us1dEISbrZ8ErWLQl
         Jd5lDPsYFHkY7hwvUoJ/9jd5++iQVEzI9E5DngI78QHx/X+5575+lwmh7n9tvs5CDkTm
         RgNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1flPHUUAFedhAd2fMzIDDL+MwERnyOqY+Bv7YRR5bhA=;
        b=BN0JE/r+w/oAfY2bPFYuPthJsirtgpJ9a8hVUNmJmFk1f7wmqmwkyNwrkwAF4FkYCN
         /aIR0NJBZyK6iOGjHEl9kJDC5o4Fk3cUWEEei6PjfvrBCxyafpki2lxZTARnygxdj8ZJ
         C/yI8Ul1g5QyqTOXi81ietw6wjndwH7njpAMH+m/slnusLazbquLMCuw8PU/913yQIvj
         vRsIPISYYkQ7/hJQJannO6nKcviv8kGAaphEjyuknpcRGXr4cIFkGb3Q2v+ia0n8qjqu
         DLHxyWNRPEJv+CnYz1JI/FwdKgC6i5mIaN/L6doHAYLYaAOdUcYjCnUNSNUEPZUc9VOq
         zqAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j3si514396eda.21.2019.02.18.09.22.37
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 09:23:30 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 70A19A78;
	Mon, 18 Feb 2019 09:22:36 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9CA853F675;
	Mon, 18 Feb 2019 09:22:33 -0800 (PST)
Subject: Re: [PATCH 01/13] arm64: mm: Add p?d_large() definitions
To: Mark Rutland <mark.rutland@arm.com>
Cc: x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-2-steven.price@arm.com>
 <20190218112922.GT32477@hirez.programming.kicks-ass.net>
 <fe36ed1c-b90d-8062-f7a9-e52d940733c4@arm.com>
 <20190218142951.GA10145@lakrids.cambridge.arm.com>
 <20190218150657.GU32494@hirez.programming.kicks-ass.net>
 <eb7e0203-db08-743b-dbed-a7032b352ded@arm.com>
 <20190218170451.GB10145@lakrids.cambridge.arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <c27d9f26-0213-3706-8bd9-ca71d20fbf06@arm.com>
Date: Mon, 18 Feb 2019 17:22:32 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190218170451.GB10145@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18/02/2019 17:04, Mark Rutland wrote:
> On Mon, Feb 18, 2019 at 03:30:38PM +0000, Steven Price wrote:
>> On 18/02/2019 15:06, Peter Zijlstra wrote:
>>> On Mon, Feb 18, 2019 at 02:29:52PM +0000, Mark Rutland wrote:
>>>> I think that Peter means p?d_huge(x) should imply p?d_large(x), e.g.
>>>>
>>>> #define pmd_large(x) \
>>>> 	(pmd_sect(x) || pmd_huge(x) || pmd_trans_huge(x))
>>>>
>>>> ... which should work regardless of CONFIG_HUGETLB_PAGE.
>>>
>>> Yep, that.
>>
>> I'm not aware of a situation where pmd_huge(x) is true but pmd_sect(x)
>> isn't. Equally for pmd_huge(x) and pmd_trans_huge(x).
>>
>> What am I missing?
> 
> Having dug for a bit, I think you're right in asserting that pmd_sect()
> should cover those.
> 
> I had worried that wouldn't cater for contiguous pmd entries, but those
> have to be contiguous section entries, so they get picked up.
> 
> That said, do we have any special handling for contiguous PTEs? We use
> those in kernel mappings regardless of hugetlb support, and I didn't
> spot a pte_large() helper.

There's no special handling for contiguous PTEs because the page walk
code doesn't care - each PTE is valid individually even if it is part of
a contiguous group. So the walker can descend all levels in this case.
pte_large() if it existed would therefore always return 0.

The pte_entry() callback obviously might go looking for the contiguous
bit so that it can annotate the output correctly but that's different
from a 'large' page. The code in arch/arm64/mm/dump.c simply looks for
the PTE_CONT bit being set to do this annotation.

Steve

