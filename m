Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69126C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:28:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32BF52171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:28:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32BF52171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B78398E0004; Thu, 28 Feb 2019 06:28:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B27118E0001; Thu, 28 Feb 2019 06:28:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3E4F8E0004; Thu, 28 Feb 2019 06:28:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBAC8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:28:09 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k21so5425140eds.19
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:28:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=rHny8Epa2KX8nVY4IJ8/IgPBrNfjhgZOct1JiTErilk=;
        b=stFHs74bfJvI0p81h8eVHA8RVBpK7CraFfA9X2yXMmRuF7i3mBlECc9JtFsANWuo+A
         cqI0V3wd0wWZ28nzCX/s5m8Sr3h4iwHvuli5RoE4h0HYAyxyTIgthUeaSWd2IW2vCac5
         LROxG7ArQ7UimGDlPHenhBcaBNT6ZknD/bS5CHF1v2kBceZqHhl+XPrtwFNWDbdmkyjW
         PMv2HD/gcSlS9SA43kZMXwNXscBk+HPcC9QswelOkYZR/IP70YuVMgxfrwwGxWcjXYYc
         9bNxePf9NNVwDlqMF3l0L0wjUmOv0nRehxm7FuSWZfXH5AXI7MPllOFZCVK/4b1BM6YS
         8fAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuacgcznSJ7NCLX1vhVONW8uDFm/AKFbHxLCS+ZYwc49Co+WiY0k
	CSMwLGHjxO1F0nggghoBSLk5DZXZJt9cwZ049yEx7pw1YHkfrwJQB1Ej08OskynlAx614bRdXmE
	R1R6yWqqiX0csCaZvdg9JSmCPTxHY7fjeISttuJ6g+tFwYTuoQahaYMFfFxjOiwGXgA==
X-Received: by 2002:a17:906:5245:: with SMTP id y5mr5050580ejm.33.1551353288874;
        Thu, 28 Feb 2019 03:28:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZzBiaUBYBRAlRVLBqQKVMay7n3xLXekBHUutg0dat6cTCBpxWhVzCjAFj8hyxOjMcv3IVP
X-Received: by 2002:a17:906:5245:: with SMTP id y5mr5050526ejm.33.1551353287858;
        Thu, 28 Feb 2019 03:28:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551353287; cv=none;
        d=google.com; s=arc-20160816;
        b=B7cxOoW1XbShgyxhAlhU1BU2vF52ZWGe/3Yt3xAAvelyQ/DxrKt47Vjl+UKqPvd0Oo
         1roEcULCHVQa+I8nm8ITGvNhq9wFgsLi2dhsIXY/TcMRp+IrfLg/odrVF3/3M7nvawJT
         9vvAwyqp2DlqpEzS+aTiLFpsDWNtJGpjoHKvi/pISVOZwtZIABtjmUNLhudKkYHrN5o5
         9Z029DeqDhpWgzAuQmflup+OTg0g36URQxhxM42G+Xfv4vCS6BTdN88GhSf1pF+7kLwo
         /Fe9E10RNN6zvfwip4pEnK/Ib7WB6MyRMiuhyg4sYKltQpwnRX27hrvqnbavnKwdxVEM
         D+cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=rHny8Epa2KX8nVY4IJ8/IgPBrNfjhgZOct1JiTErilk=;
        b=Jwk6U3szKtUoyjNq0dhNPgdSQZO3yVdTLPHBceg36hThjzRzIyjUBW9g08CgaMLmk7
         NlMZXo8MvKDJ08w5WFG/lQH8Gvthqh6HMt4rovTrBe2cEBPRNg8OVHllJHcwN4/WMZOI
         im6UhycgPFmM2pDc9zs8mCErWw/B0SOBOYqedcBfSsVXJ0Wc9bGJdaoeXgntMCZJgDYd
         ZBTJjYZhyuhYeWjrNu8eBdINVkkSjGoXl4FCfnPCy7AI6uSiddS8xvi16+dobeNV0IOH
         iEWNlEhoQVf5sZtV3S26UIywiK2u8I0lpA6YowYj6aPZxaigyrZ/O7JGEgUq5HV1bYzp
         UAEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i4si3645945edg.422.2019.02.28.03.28.07
        for <linux-mm@kvack.org>;
        Thu, 28 Feb 2019 03:28:07 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8A9D9EBD;
	Thu, 28 Feb 2019 03:28:06 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6AABA3F738;
	Thu, 28 Feb 2019 03:28:03 -0800 (PST)
Subject: Re: [PATCH v3 27/34] mm: pagewalk: Add 'depth' parameter to pte_hole
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-28-steven.price@arm.com>
 <aece3046-6040-e2ec-fcd7-204113d40eb7@intel.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <02b9ec67-75c5-4a36-9110-cc4ba6ee4f94@arm.com>
Date: Thu, 28 Feb 2019 11:28:01 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <aece3046-6040-e2ec-fcd7-204113d40eb7@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27/02/2019 17:38, Dave Hansen wrote:
> On 2/27/19 9:06 AM, Steven Price wrote:
>>  #ifdef CONFIG_SHMEM
>>  static int smaps_pte_hole(unsigned long addr, unsigned long end,
>> -		struct mm_walk *walk)
>> +			  __always_unused int depth, struct mm_walk *walk)
>>  {
> 
> I think this 'depth' argument is a mistake.  It's synthetic and it's
> surely going to be a source of bugs.
> 
> The page table dumpers seem to be using this to dump out the "name" of a
> hole which seems a bit bogus in the first place.  I'd much rather teach
> the dumpers about the length of the hole, "the hole is 0x12340000 bytes
> long", rather than "there's a hole at this level".

I originally started by trying to calculate the 'depth' from (end -
addr), e.g. for arm64:

level = 4 - (ilog2(end - addr) - PAGE_SHIFT) / (PAGE_SHIFT - 3)

However there are two issues that I encountered:

* walk_page_range() takes a range of addresses to walk. This means that
holes at the beginning/end of the range are clamped to the address
range. This particularly shows up at the end of the range as I use ~0ULL
as the end which leads to (~0ULL - addr) which is 1 byte short of the
desired size. Obviously that particular corner-case is easy to work
round, but it seemed fragile.

* The above definition for arm64 isn't correct in all cases. You need to
account for things like CONFIG_PGTABLE_LEVELS. Other architectures also
have various quirks in their page tables.

I guess I could try something like:

static int get_level(unsigned long addr, unsigned long end)
{
	/* Add 1 to account for ~0ULL */
	unsigned long size = (end - addr) + 1;
	if (size < PMD_SIZE)
		return 4;
	else if (size < PUD_SIZE)
		return 3;
	else if (size < P4D_SIZE)
		return 2;
	else if (size < PGD_SIZE)
		return 1;
	return 0;
}

There are two immediate problems with that:

 * The "+1" to deal with ~0ULL is fragile

 * PGD_SIZE isn't what you might expect, it's not defined for most
architectures and arm64/x86 use it as the size of the PGD table.
Although that's easy enough to fix up.

Do you think a function like above would be preferable?

The other option would of course be to just drop the information from
the debugfs file about at which level the holes are. But it can be
useful information to see whether there are empty levels in the page
table structure. Although this is an area where x86 and arm64 differ
currently (x86 explicitly shows the gaps, arm64 doesn't), so if x86
doesn't mind losing that functionality that would certainly simplify things!

Thanks,

Steve

