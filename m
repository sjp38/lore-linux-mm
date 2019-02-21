Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88DA3C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:16:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 524642083B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:16:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 524642083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2E9C8E0096; Thu, 21 Feb 2019 12:16:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDD9C8E0094; Thu, 21 Feb 2019 12:16:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCC938E0096; Thu, 21 Feb 2019 12:16:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7154B8E0094
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 12:16:55 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id h16so803481edq.16
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:16:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=T5pCdQuJa6qjFtndqfSmIWwwLvyJm5/kjzInfeVZBTU=;
        b=SY0LAXKRzXQxGTOpIZMeFjjV6BwvaXS8nQSdpkqYhCi7Njj1iUpZLMt6xy/hSnswk2
         BpgsBeluXHFK5dOSv3UM7VRkpL2IaS73J/mmMabAnxXZq05ngoeZFQPSiaEoykByF37u
         S808ufHXWQM6V8HxEH5FaGBcKfcz0x/d2OkibPnxAfrE6D4iOjXC20Yz8DEk9urZwXo6
         haTr80Y0hE3RGE715qXFVF1MhXHZKMoCjnIyNAuww5p7M0uHJuWfztT0gN3aTIxvX5Ll
         nh9h/brixuJQI6i6t59sJndytls0kNcbrbHIlCaa8MIaXHy7VhJEjfsI+5PUBX38k9fo
         EJfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuawWWT3kb8fGF91Mjtun2wetxbOjuOcHjlJv/RBCxs8FC1yE4MH
	PURI7MjR/IzrsjpWJBoAvFSJhNaCJyGj1JpFOt2cI1Ss1mmHX1mffQmSaPpJ4wjFhJcFx1eWZW2
	PSEr8LMNdQueDh3gQhwN7PAlx4EN+REYwRUPQcNGrOj5GZ2fCtXcrVIwex9u3uAXGow==
X-Received: by 2002:a17:906:b793:: with SMTP id dt19mr14312324ejb.168.1550769414924;
        Thu, 21 Feb 2019 09:16:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYKcqyBqSuI2WCNfjdZ1bvgyqnGrtX+ylcw7UrewtwBZkU8Y2FmxfeQl8GoTD4WJikF0o3d
X-Received: by 2002:a17:906:b793:: with SMTP id dt19mr14312263ejb.168.1550769413854;
        Thu, 21 Feb 2019 09:16:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550769413; cv=none;
        d=google.com; s=arc-20160816;
        b=CmHJWNHwkxR9icxvEVF23dWLd1hhhTtfln0q5Gj4tGX1C87EJkXQajArbknkyJmyTL
         ZQYvY8OkeF9nsoDajDjGZs/vhxvhp4PN9OTYL10SosVRvtZSQjW5+e2+BJ/6hCqz0Oyk
         PvwYgfOKRbigrXnxq9bHPr8FdnQvuQjnZ68pifKpnHDM5sljAZaZ+fFRPMaCC2R+blvh
         ynuWMGMwM8FpZec1NTXyX8oeidOTI3phTG5fQNwgIScT6F+JD8KSVLQu3zFFBifkTfGu
         bztCfIvqaceMsK2KVvRcRl/jzQVYEdAVKjuvtpvJe79oFGkBQhKGDqzY80kAgRdwTVWx
         KOQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=T5pCdQuJa6qjFtndqfSmIWwwLvyJm5/kjzInfeVZBTU=;
        b=h5veVYa+vK5uSw95LugAY0Vpwsq/jLVNu81gup0w0JVxWxRPq2FO5pUNcm+N/Y/GRD
         phYkLFLkoiXCn612yAHRaF8J2+wF4eEehE/NFPB5aJJEJouyvGiCvVJ8KsviLO69iduS
         nSjrGxJ9GgaY53y894CaU4zD0EGAtRmrDVD67azrNwnj7BOKR63AFDV3V+uVibYvr08/
         dANW3NcmXEjI8zJTEBqD/mdmSuvf3hWaNiQwuPa6oU+Erd5pp5US+OX+C643xtvAmkoQ
         G9FVV3lCuym8CfDHrD6mc2Po2ZYATcVCCzr3B7xcapnyovpzYWcjTCTTIT64UTpx04Bi
         +X7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k27si739555ejb.162.2019.02.21.09.16.53
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 09:16:53 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 52E93A78;
	Thu, 21 Feb 2019 09:16:52 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A8D433F5C1;
	Thu, 21 Feb 2019 09:16:48 -0800 (PST)
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mark Rutland <Mark.Rutland@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
 Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-4-steven.price@arm.com>
 <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
 <a3076d01-41b3-d59b-e98c-a0fd9ba5d3f5@arm.com>
 <20190221145706.zqwfdoyiirn3lc7y@kshutemo-mobl1>
From: Steven Price <steven.price@arm.com>
Message-ID: <e0c7fc0c-7924-1106-a7a3-fc12136b7b82@arm.com>
Date: Thu, 21 Feb 2019 17:16:46 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190221145706.zqwfdoyiirn3lc7y@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 21/02/2019 14:57, Kirill A. Shutemov wrote:
> On Thu, Feb 21, 2019 at 02:46:18PM +0000, Steven Price wrote:
>> On 21/02/2019 14:28, Kirill A. Shutemov wrote:
>>> On Thu, Feb 21, 2019 at 11:34:52AM +0000, Steven Price wrote:
>>>> From: James Morse <james.morse@arm.com>
>>>>
>>>> Exposing the pud/pgd levels of the page tables to walk_page_range() means
>>>> we may come across the exotic large mappings that come with large areas
>>>> of contiguous memory (such as the kernel's linear map).
>>>>
>>>> For architectures that don't provide p?d_large() macros, provided a
>>>> does nothing default.
>>>
>>> Nak, sorry.
>>>
>>> Power will get broken by the patch. It has pmd_large() inline function,
>>> that will be overwritten by the define from this patch.
>>>
>>> I believe it requires more ground work on arch side in general.
>>> All architectures that has huge page support has to provide these helpers
>>> (and matching defines) before you can use it in a generic code.
>>
>> Sorry about that, I had compile tested on power, but obviously not the
>> right config to actually see the breakage.
> 
> I don't think you'll catch it at compile-time. It would silently override
> the helper with always-false.

Ah, that might explain why I missed it.

>> I'll do some grepping - hopefully this is just a case of exposing the
>> functions/defines that already exist for those architectures.
> 
> I see the same type of breakage on s390 and sparc.
> 
>> Note that in terms of the new page walking code, these new defines are
>> only used when walking a page table without a VMA (which isn't currently
>> done), so architectures which don't use p?d_large currently will work
>> fine with the generic versions. They only need to provide meaningful
>> definitions when switching to use the walk-without-a-VMA functionality.
> 
> How other architectures would know that they need to provide the helpers
> to get walk-without-a-VMA functionality? This looks very fragile to me.

Yes, you've got a good point there. This would apply to the p?d_large
macros as well - any arch which (inadvertently) uses the generic version
is likely to be fragile/broken.

I think probably the best option here is to scrap the generic versions
altogether and simply introduce a ARCH_HAS_PXD_LARGE config option which
would enable the new functionality to those arches that opt-in. Do you
think this would be less fragile?

Thanks,

Steve

