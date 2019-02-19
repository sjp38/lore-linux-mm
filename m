Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B7AEC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:44:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1730021900
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 03:44:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1730021900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B94B08E0003; Mon, 18 Feb 2019 22:44:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B41848E0002; Mon, 18 Feb 2019 22:44:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A09DA8E0003; Mon, 18 Feb 2019 22:44:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5B68E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 22:44:16 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id x11so1672683pln.5
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 19:44:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=YsGSrMeswCIuwLpmsobSpe8mtBrnuD5RRkZcz/H5uW0=;
        b=cOPRux0VBZ46gKVc1siFiLWf2l+6Voxo6lq831WfUnzzOVtjrc20zqqerpdQMoi+P3
         638yFkEr4CXW9KaLYmJeYmWYt1kBg2+a4wFoxdHU04AeyyG6QFm+B9HrvqJlzF8zoNV0
         gzk2oxUN8ka4bKJhmG4S2MjpWWLM7gVdtFWB/9q590umtqgZlmGpahwVIWjwUWd5uPpv
         Hwqs5pELcesgn0WPbFiKN8UTudiOlmB2o+QlYATRypYegueIJOxXvii8nTvyaiflDWpm
         LAswZrdPMtToCSkSKapNi+gVHbBGlhDGa1L9St0goJXE7nKeeRfHkZciQ+EYn/On0FZ7
         lT9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kan.liang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kan.liang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZEURg/wPTbiDgfbN1IptE/wUi86crmccE7cvkD9ol23Pa6Vn4k
	S2tjVt2N10Ui8PHK80yEirt/je+y1hh6MS6xKpT70PYKee9QWzSE7aEP84iH3I25SSFAR5ey/9Z
	gxb8EYURmfhsZX+7QQNDRgh+xfu0eSODHxwsy6/2/dIjK84GVBle/Payl4xzWEk99DA==
X-Received: by 2002:aa7:8045:: with SMTP id y5mr27234707pfm.62.1550547856024;
        Mon, 18 Feb 2019 19:44:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia4YTFyLi+ac5ixiEYom8kRqX4r051gRbmxob7K4efSZihcHlCwQl9X0ODS8LJjBAb6VN3W
X-Received: by 2002:aa7:8045:: with SMTP id y5mr27234659pfm.62.1550547855208;
        Mon, 18 Feb 2019 19:44:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550547855; cv=none;
        d=google.com; s=arc-20160816;
        b=D9btV4JE1Z7WFJnRB6yBtamgevGenm5sbcKwmY16ZFVS8TLsl+nW87/jYMKhF4NYsb
         +oIBXURZJXVZwg+oAbwQguyweQ21PQfjBYer7oy8ItWFFVek4w96UR3uZ4TIPWvV3+Cb
         xKiaT6GnAuj9q0F1/Pb2H5BQav60FMM6tWSHNz78ZyGqZcsPYMCMF+3gH1POPOYwhnjV
         Fog9gGLXBQyTxB7vLKQEuESh5cjznSlGLa7BWWQPAahAhURQvWWfnJ+sgwrFJRnRvCzK
         VTPlcOodr5OTZWexsdVAkTiTTACr5NQZ9A1ETjTE0jWXWX4rWCLKFr8J/rbYUAKn21r2
         EiIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=YsGSrMeswCIuwLpmsobSpe8mtBrnuD5RRkZcz/H5uW0=;
        b=DsH8cxSc+TqSe5RD3TS7b0McvRerQu0auU04AV8h12nKDr78KtdzzAQZf/1h3TCG/c
         iXs44Q9pCG8x12Knct18EROs6gifYDw7L1XcOGkHjM05cbx42NlH8jjcd4a7pVfA79Xk
         +IUbnOSAvZ9OBCIfKJ1sJmL+fmUxUmx96TUdVa3DrpdAxWSrzKjN6kKZ+zLjaJwCPny6
         t6ktRAeG87W+2YlfFqNcqGfEvCBBw3EofXrAuTe8byOS1dTBy3q3vVPq+6aPEwYJ6qKP
         Ocj4nRkDm8ZueeYJ4c/gzSuaCUCz/5oPT75gBEHHU83KjQZ4jTPuW3hmG3nFE+dqXnJy
         R9ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kan.liang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kan.liang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b8si8323752plx.131.2019.02.18.19.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 19:44:15 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of kan.liang@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kan.liang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kan.liang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Feb 2019 19:44:14 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,385,1544515200"; 
   d="scan'208";a="127491915"
Received: from linux.intel.com ([10.54.29.200])
  by orsmga003.jf.intel.com with ESMTP; 18 Feb 2019 19:44:14 -0800
Received: from [10.254.86.162] (kliang2-mobl1.ccr.corp.intel.com [10.254.86.162])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by linux.intel.com (Postfix) with ESMTPS id 58CD1580238;
	Mon, 18 Feb 2019 19:44:12 -0800 (PST)
Subject: Re: [PATCH 03/13] mm: Add generic p?d_large() macros
To: Steven Price <steven.price@arm.com>, Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Catalin Marinas <catalin.marinas@arm.com>, kirill@shutemov.name,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-4-steven.price@arm.com>
 <20190218113134.GU32477@hirez.programming.kicks-ass.net>
 <aad21496-a86b-ca91-70b7-0c23ea6fefd3@arm.com>
From: "Liang, Kan" <kan.liang@linux.intel.com>
Message-ID: <8a74c111-b099-8d18-5fb0-422909a1367a@linux.intel.com>
Date: Mon, 18 Feb 2019 22:44:10 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <aad21496-a86b-ca91-70b7-0c23ea6fefd3@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/18/2019 9:19 AM, Steven Price wrote:
> On 18/02/2019 11:31, Peter Zijlstra wrote:
>> On Fri, Feb 15, 2019 at 05:02:24PM +0000, Steven Price wrote:
>>> From: James Morse <james.morse@arm.com>
>>>
>>> Exposing the pud/pgd levels of the page tables to walk_page_range() means
>>> we may come across the exotic large mappings that come with large areas
>>> of contiguous memory (such as the kernel's linear map).
>>>
>>> For architectures that don't provide p?d_large() macros, provided a
>>> does nothing default.
>>
>> Kan was going to fix that for all archs I think..
>

Yes, I'm still working on a generic function to retrieve page size.
The generic p?d_large() issue has been fixed. However, I found that the 
pgd_page() is not generic either. I'm still working on it.
I will update you on the other thread when all issues are fixed.



> The latest series I can find from Kan is still x86 specific. I'm happy
> to rebase onto something else if Kan has an implementation already
> (please point me in the right direction). Otherwise Kan is obviously
> free to base on these changes.
>

My implementation is similar as yours. I'm happy to re-base on your changes.

Could you please also add a generic p4d_large()?

Thanks,
Kan

> Steve
> 
>> See:
>>
>>    http://lkml.kernel.org/r/20190204105409.GA17550@hirez.programming.kicks-ass.net
>>
>>> Signed-off-by: James Morse <james.morse@arm.com>
>>> Signed-off-by: Steven Price <steven.price@arm.com>
>>> ---
>>>   include/asm-generic/pgtable.h | 10 ++++++++++
>>>   1 file changed, 10 insertions(+)
>>>
>>> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
>>> index 05e61e6c843f..7630d663cd51 100644
>>> --- a/include/asm-generic/pgtable.h
>>> +++ b/include/asm-generic/pgtable.h
>>> @@ -1186,4 +1186,14 @@ static inline bool arch_has_pfn_modify_check(void)
>>>   #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
>>>   #endif
>>>   
>>> +#ifndef pgd_large
>>> +#define pgd_large(x)	0
>>> +#endif
>>> +#ifndef pud_large
>>> +#define pud_large(x)	0
>>> +#endif
>>> +#ifndef pmd_large
>>> +#define pmd_large(x)	0
>>> +#endif
>>> +
>>>   #endif /* _ASM_GENERIC_PGTABLE_H */
>>> -- 
>>> 2.20.1
>>>
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>>
> 

