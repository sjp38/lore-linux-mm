Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 24A836B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:04:46 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so60687352pdb.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 11:04:45 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id e4si8096106pdp.245.2015.04.15.11.04.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 11:04:45 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NMV00G9B12CB450@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Apr 2015 19:08:36 +0100 (BST)
Message-id: <552EA835.5070704@samsung.com>
Date: Wed, 15 Apr 2015 21:04:37 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 2/2] arm64: add KASan support
References: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com>
 <1427208544-8232-3-git-send-email-a.ryabinin@samsung.com>
 <20150401122843.GA28616@e104818-lin.cambridge.arm.com>
 <551E993E.5060801@samsung.com> <552DCED9.40207@codeaurora.org>
In-reply-to: <552DCED9.40207@codeaurora.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Keitel <dkeitel@codeaurora.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On 04/15/2015 05:37 AM, David Keitel wrote:
>>>> +	pgd = __pgd(__pa(kasan_zero_pmd) | PAGE_KERNEL);
>>>> +#else
>>>> +	pgd = __pgd(__pa(kasan_zero_pte) | PAGE_KERNEL);
>>>> +#endif
>>>> +
>>>> +	for (i = pgd_index(start); start < end; i++) {
>>>> +		set_pgd(&pgdp[i], pgd);
>>>> +		start += PGDIR_SIZE;
>>>> +	}
>>>> +}
>>>
>>> Same problem as above with PAGE_KERNEL. You should just use
>>> pgd_populate().
> 
> Any suggestion what the correct flag setting would be here for a 4K mapping?
> 
> I tried fixing this by changing this to pud and setting the PMD_TYPE_TABLE flag for kasan_zero_pmd. However the MMU doesn't like it and I get a first level address translation fault.
> 
> If you have any updated patches to share I'd be glad to try them out.
> 

Sorry, I didn't have much time on work on this yet.

I've pushed the most fresh thing that I have in git:
	git://github.com/aryabinin/linux.git kasan/arm64v1

It's the same patches with two simple but important fixes on top of it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
