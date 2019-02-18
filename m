Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23F90C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:11:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED3DB21901
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:11:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED3DB21901
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89AB08E0003; Mon, 18 Feb 2019 09:11:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8238C8E0002; Mon, 18 Feb 2019 09:11:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7129C8E0003; Mon, 18 Feb 2019 09:11:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1330D8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:11:52 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d62so7275143edd.19
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:11:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=xqoNOqg1iSXVBFpRUeWxRSzvi5/YhOf8aybzzzeil2A=;
        b=hgOYA5Hhw125X8QibqKJbk7rHe5lF/4xht2WpI9XhWIgcl7hi0+hWnF46teSVnxlT1
         9SA8oUarKtycKo7qRMRq8H4NVlYJ2XsLypOLla5+bA+XdzmUfaYgIrdeVBj0oB5rzjBi
         d2UXIqBz2dkzodrNI513k96yxM7poZd71Vya6KK4mfmntC9Hu8AjJanswAfCDWmYHIfN
         MWj6D2HjzM0ri5joZ4oyyYhqmVICDAjkXwbRtKA9DXtmOXQjzW9uUP/Pb7TqsUyOvdMB
         V1Psm2nRFjGpMfEo3UAvR0AcsCZGc4XBMYZ2QE0gry7FjUdPUS2qCo10QTl5aM7kpIUA
         2KvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubW+pNw2YYyzh5WmzD68MsdosDYbo27v6TZaX39EFuKzxgEdvVx
	DeLQX6ZZUo7KvUSRY38dFsS7XR+2EWkaQ2N2AaYINEZx5O0BBciX5AthbqKmQp8jcPyz0AwMpja
	0ypBLikdOeMuZPcVg7PEGT38tFEYgqMJM7lLJccVkuMaQWyW6VmMGU+5c8AH4uwHw8Q==
X-Received: by 2002:aa7:d1d7:: with SMTP id g23mr18482280edp.217.1550499111617;
        Mon, 18 Feb 2019 06:11:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYv0oRKUd0nyBK6WaSbVun0843Ty1ATzmDU65JLV92pWCB4umiSjQszHu8ABZZAsEc00euY
X-Received: by 2002:aa7:d1d7:: with SMTP id g23mr18482214edp.217.1550499110641;
        Mon, 18 Feb 2019 06:11:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550499110; cv=none;
        d=google.com; s=arc-20160816;
        b=LP0NW1vbG1DlwkadkQAh28Yo7EFLPeYLS9ghqhchylsTwpD49LlOPg51SazWcEA3l2
         YjXH9YYjwSFr+1H3KMseKact6GxOkvdeLh3wRrZUKXn4finc9H0YUH0RJ0WLepIWBa46
         DxyBSARpeAyNDNUe+n5aSr9tYEv7NrsDkwi09mgJH9QRlZPES1GRlwub6ySs5sRzMFb7
         CN20dXM4GNncvMPag7u82cadfIlu37TFfLjuWu1M0ei5Obz50wlO6wv9dUotlrZU1M3y
         oBkEoYR54dY+0RlGARDz4+c3IgPQeZIuocQP6KfL9XzBK7CWdSUYwOeRNgrcgUduVmWM
         8Jiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xqoNOqg1iSXVBFpRUeWxRSzvi5/YhOf8aybzzzeil2A=;
        b=f0FCE8UF2q4zDhHVxHyqQsSiNfdOzsKFmtRlj1y/FiwSGC/Yfb1m7CBLLuAWt4B5gi
         Oaz4Ew5y0B8lRQYia312lHtqcMHD72LXCza6eNuwhQO0+c4NFxkQXdqxxSlhqBFIHxtC
         QSGzIE/36zBnm6f1fCIFylOfaPj1C56GiPnybvasPy2eOZkaIPJsrHVIksFIcznd2aDu
         ExvI1X8hrssNM0qLfV2vPKnGE2J9kyS7CVF8gscGPja2gcpFNkG9xZAUagFIKYpl7RNF
         xBdlE7ZZaf9PwlzhK6I9LrEqaFPE+jlbJAkkJWv0RMBYks68xOPrI24JREmG8Q9i7ljL
         Vmqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n17si1686645edd.333.2019.02.18.06.11.46
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 06:11:50 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5EB10A78;
	Mon, 18 Feb 2019 06:11:45 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id ACC763F589;
	Mon, 18 Feb 2019 06:11:42 -0800 (PST)
Subject: Re: [PATCH 01/13] arm64: mm: Add p?d_large() definitions
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>,
 James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Thomas Gleixner <tglx@linutronix.de>,
 Will Deacon <will.deacon@arm.com>, x86@kernel.org,
 "H. Peter Anvin" <hpa@zytor.com>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-2-steven.price@arm.com>
 <20190218112922.GT32477@hirez.programming.kicks-ass.net>
From: Steven Price <steven.price@arm.com>
Message-ID: <fe36ed1c-b90d-8062-f7a9-e52d940733c4@arm.com>
Date: Mon, 18 Feb 2019 14:11:40 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190218112922.GT32477@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18/02/2019 11:29, Peter Zijlstra wrote:
> On Fri, Feb 15, 2019 at 05:02:22PM +0000, Steven Price wrote:
> 
>> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
>> index de70c1eabf33..09d308921625 100644
>> --- a/arch/arm64/include/asm/pgtable.h
>> +++ b/arch/arm64/include/asm/pgtable.h
>> @@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>>  				 PMD_TYPE_TABLE)
>>  #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
>>  				 PMD_TYPE_SECT)
>> +#define pmd_large(x)		pmd_sect(x)
>>  
>>  #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
>>  #define pud_sect(pud)		(0)
>> @@ -435,6 +436,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>>  #else
>>  #define pud_sect(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
>>  				 PUD_TYPE_SECT)
>> +#define pud_large(x)		pud_sect(x)
>>  #define pud_table(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
>>  				 PUD_TYPE_TABLE)
>>  #endif
> 
> So on x86 p*d_large() also matches p*d_huge() and thp, But it is not
> clear to me this p*d_sect() thing does so, given your definitions.
> 
> See here why I care:
> 
>   http://lkml.kernel.org/r/20190201124741.GE31552@hirez.programming.kicks-ass.net
> 

pmd_huge()/pud_huge() unfortunately are currently defined as '0' if
!CONFIG_HUGETLB_PAGE and for this reason I was avoiding using them.
While most code would reasonably not care about huge pages in that build
configuration, the likes of the debugfs page table dump code needs to be
able to recognise them in all build configurations. I believe the
situation is the same on arm64 and x86.

The other quirk is that higher levels are not supported for HUGETLB on
some arch implementations. For example arm64 provides no definition for
pgd_huge() so falls back to the generic defined as '0' implementation.
The only architecture I can see that defines this is powerpc. Keeping
this as '0' ensures that the otherwise dead code in other places is
compiled out.

Where p?d_huge is defined by the arch code the intention is that
p?d_large(x)==p?d_huge(x).

Thanks,

Steve

