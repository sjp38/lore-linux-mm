Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85CE4C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 10:21:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A82B2086C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 10:21:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A82B2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC7888E00F7; Fri, 22 Feb 2019 05:21:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D78A78E00EA; Fri, 22 Feb 2019 05:21:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65AB8E00F7; Fri, 22 Feb 2019 05:21:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0118E00EA
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 05:21:47 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o25so615252edr.0
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 02:21:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FwI7iCaf14wKRLncAqnIQ9D2TFMeOu3qiL53QbkyqpQ=;
        b=r1glbv/seBQ+lJ1UtVa/FJYh5g3jOFFHOHQzXExusmNJm8/XZdsmSgIQmOVYudsDsJ
         16KzEsKQUIXqdY3Ll4BTYdeZKioLhx4oCzN0ApGBCFoNrqavaUnfBhnigUvERkgFJC++
         +w7Cfr5Wd9xBhIP6rgdp6nMUd4coZeWVQgpuuzTpjZ5YFrE7pboviE30i+WhYTwC7XOc
         PpCxf+zE+mo6Fj976Vj8EzGWPq0sHFlcyLlG/UKOUrH+LbTc6S3usT8UZ4y6NiWD6Hfa
         X7rC0jlO7Mf0kPBRmIuo4/A6XopHaZBjhoC3CO83aserAoECuJ05B3ZQ4zP0luD7E3Aj
         E/lQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubKl5rqGXUVLDLz3DZDkXpMn3pLTOSQsnZVvh0a8wPG+qE6isLc
	g5G4/j3wM3bmbI2wgLX+V/XalfM75642gIliK7U1f1gs3ZmuKds18Cn2N4IluvxyngRIN4FMJON
	8f/6IdNkOA6krAs6A/WUAea08MTOQuQDLZYxB2LJ9gnqy3asgD8fcmhqFemnjnMMkCg==
X-Received: by 2002:a50:a7c4:: with SMTP id i62mr2629809edc.162.1550830906830;
        Fri, 22 Feb 2019 02:21:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaokbUj7T4TB7hrMPYSFUPymisWAUPMvHg6dkKlH0Jznrl4uFaM1r3ugFN5Ryw7UQu6z5+h
X-Received: by 2002:a50:a7c4:: with SMTP id i62mr2629755edc.162.1550830905838;
        Fri, 22 Feb 2019 02:21:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550830905; cv=none;
        d=google.com; s=arc-20160816;
        b=nHvdQD0XQv/S8HxryMyuUY3bXMYsB3xEy+mvDRuoj4PGr86Y0mVHXtltXtFkDSs8Kh
         yVDQku0vFEOMb6Ekz8aC2Jg957LeJjFuvzVv7pW/UbskLwgBdOvov7FPgXeIrYLN+rzn
         ygy+WPFVdxIDDaIvFgcFcA7baAJ6JzXCYEitPMLkoEuZGmt8Sh8IwL5s8wF00wQqIIk0
         tbBI2v8yshSBD+T53raAmakE4dn3QPYCnu7gj8rLDv7RbykKPxB3Bfb/Uc9roUgwcObN
         1YBvuxn3yOmU+84nPtMPAX00wjzYNmafKaIqyIQksnXncZej3By5iLk/J1Ce//CtanxB
         N7dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=FwI7iCaf14wKRLncAqnIQ9D2TFMeOu3qiL53QbkyqpQ=;
        b=MjFk8mdxrtN4Bw6XdB38ideUJNywxTd5Zn0gggFyjShip1/J0RKYH09goMUlSRCH35
         IDDJ6n7mXelMRHHEhPt9k8sETsYjGwDCRA8tEViAmqSoLV2HKaTAy5j4kt79uvOB6faw
         jwXYXE116Ieqh07cTzOvKcerQ8+9U9KYFFw2nmCDH4Xekc24CMBGPjk8urI6Ic041rtA
         et5MqkQAMJvozmyrfFDLCpkThi8i1Ykn8joFlpQsVH1Qu2JdgJCxxUMtYAuQlRbiTxYZ
         9sK4SZIKXRQ8fncxTubE2v5x9pz/ruztbqaM28bqEmZ6aKZlPPGq5QyrvjuqHcmu8LcI
         s3UA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k52si492526edd.233.2019.02.22.02.21.45
        for <linux-mm@kvack.org>;
        Fri, 22 Feb 2019 02:21:45 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C24EB80D;
	Fri, 22 Feb 2019 02:21:44 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A30923F703;
	Fri, 22 Feb 2019 02:21:41 -0800 (PST)
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
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
 <e0c7fc0c-7924-1106-a7a3-fc12136b7b82@arm.com>
 <20190221210618.voyfs5cnafpvgedh@kshutemo-mobl1>
From: Steven Price <steven.price@arm.com>
Message-ID: <9441949b-6982-eea3-a05e-e277776ff821@arm.com>
Date: Fri, 22 Feb 2019 10:21:40 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190221210618.voyfs5cnafpvgedh@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 21/02/2019 21:06, Kirill A. Shutemov wrote:
> On Thu, Feb 21, 2019 at 05:16:46PM +0000, Steven Price wrote:
>>>> Note that in terms of the new page walking code, these new defines are
>>>> only used when walking a page table without a VMA (which isn't currently
>>>> done), so architectures which don't use p?d_large currently will work
>>>> fine with the generic versions. They only need to provide meaningful
>>>> definitions when switching to use the walk-without-a-VMA functionality.
>>>
>>> How other architectures would know that they need to provide the helpers
>>> to get walk-without-a-VMA functionality? This looks very fragile to me.
>>
>> Yes, you've got a good point there. This would apply to the p?d_large
>> macros as well - any arch which (inadvertently) uses the generic version
>> is likely to be fragile/broken.
>>
>> I think probably the best option here is to scrap the generic versions
>> altogether and simply introduce a ARCH_HAS_PXD_LARGE config option which
>> would enable the new functionality to those arches that opt-in. Do you
>> think this would be less fragile?
> 
> These helpers are useful beyond pagewalker.
> 
> Can we actually do some grinding and make *all* archs to provide correct
> helpers? Yes, it's tedious, but not that bad.
> 
> I think we could provide generic helpers for folded levels in
> <asm-generic/pgtable-nop?d.h> and rest has to be provided by the arch.
> Architectures that support only 2 level paging would need to provide
> pgd_large(), with 3 -- pmd_large() and so on.

Fair enough, I'll have a go and hopefully people will be able to correct
it if I make any mistakes - I'm certainly not going to be able to test
all architectures myself.

Steve

