Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DD806B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 09:43:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j18so1616712pfn.17
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 06:43:09 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id b73-v6si1310146pli.305.2018.04.27.06.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 06:43:07 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] x86/mm: implement free pmd/pte page interfaces
References: <20180314180155.19492-1-toshi.kani@hpe.com>
 <20180314180155.19492-3-toshi.kani@hpe.com>
 <20180426141926.GN15462@8bytes.org> <1524759629.2693.465.camel@hpe.com>
 <20180426172327.GQ15462@8bytes.org> <1524764948.2693.478.camel@hpe.com>
 <20180426200737.GS15462@8bytes.org> <1524781764.2693.503.camel@hpe.com>
 <20180427073719.GT15462@8bytes.org>
 <5b237058-6617-6af3-8499-8836d95f538d@codeaurora.org>
 <20180427124828.GW15462@8bytes.org>
From: Chintan Pandya <cpandya@codeaurora.org>
Message-ID: <fb4771ca-694b-8a52-d239-1c730617600b@codeaurora.org>
Date: Fri, 27 Apr 2018 19:12:57 +0530
MIME-Version: 1.0
In-Reply-To: <20180427124828.GW15462@8bytes.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "joro@8bytes.org" <joro@8bytes.org>
Cc: "guohanjun@huawei.com" <guohanjun@huawei.com>, "Hocko, Michal" <MHocko@suse.com>, "Kani, Toshi" <toshi.kani@hpe.com>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "x86@kernel.org" <x86@kernel.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mingo@redhat.com" <mingo@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "bp@suse.de" <bp@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>



On 4/27/2018 6:18 PM, joro@8bytes.org wrote:
> On Fri, Apr 27, 2018 at 05:22:28PM +0530, Chintan Pandya wrote:
>> I'm bit confused here. Are you pointing to race within ioremap/vmalloc
>> framework while updating the page table or race during tlb ops. Since
>> later is arch dependent, I would not comment. But if the race being
>> discussed here while altering page tables, I'm not on the same page.
> 
> The race condition is between hardware and software. It is not
> sufficient to just remove the software references to the page that is
> about to be freed (by clearing the PMD/PUD), also the hardware
> references in the page-walk cache need to be removed with a TLB flush.
> Otherwise the hardware can use the freed (and possibly reused) page to
> establish new TLB entries.

Sure ! This is my understanding too (from arm64 context).

> 
> 
> 
> 	Joerg
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

Chintan
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, a Linux Foundation
Collaborative Project
