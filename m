Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D068A6B0038
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 11:21:05 -0500 (EST)
Received: by wmww144 with SMTP id w144so27540945wmw.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 08:21:05 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0054.outbound.protection.outlook.com. [157.55.234.54])
        by mx.google.com with ESMTPS id dc7si409583wjc.14.2015.11.20.08.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 08:21:04 -0800 (PST)
Subject: Re: [PATCH v3] arm64: Add support for PTE contiguous bit.
References: <1447952231-17631-1-git-send-email-dwoods@ezchip.com>
 <5D0C7112-063F-4116-9585-ADF4ADF97AAE@gmail.com>
From: David Woods <dwoods@ezchip.com>
Message-ID: <564F4861.5020002@ezchip.com>
Date: Fri, 20 Nov 2015 11:20:49 -0500
MIME-Version: 1.0
In-Reply-To: <5D0C7112-063F-4116-9585-ADF4ADF97AAE@gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, steve.capper@linaro.org, jeremy.linton@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmetcalf@ezchip.com

On 11/20/2015 05:07 AM, yalin wang wrote:
>> +
>> +void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>> +			    pte_t *ptep, pte_t pte)
>> +{
>> +	size_t pgsize;
>> +	int i;
>> +	int ncontig = find_num_contig(mm, addr, ptep, pte, &pgsize);
>> +	unsigned long pfn;
>> +	pgprot_t hugeprot;
>> +
>> +	if (ncontig == 1) {
>> +		set_pte_at(mm, addr, ptep, pte);
>> +		return;
>> +	}
>> +
>> +	pfn = pte_pfn(pte);
>> +	hugeprot = __pgprot(pte_val(pfn_pte(pfn, 0) ^ pte_val(pte)));
> is this should be pte_val(pfn_pte(pfn, 0)) ^ pte_val(pte)  ?
>
The code generated is identical either way, but I agree your way looks 
better.

-Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
