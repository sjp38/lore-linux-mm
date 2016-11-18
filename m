Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4D66B0399
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 21:48:25 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e9so231927601pgc.5
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:48:25 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i17si5808456pgj.71.2016.11.17.18.48.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 18:48:24 -0800 (PST)
Subject: Re: [PATCH] mremap: fix race between mremap() and page cleanning
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
 <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com>
Date: Fri, 18 Nov 2016 10:48:20 +0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>

On 11/18/2016 01:53 AM, Linus Torvalds wrote:
> On Thu, Nov 10, 2016 at 1:16 AM, Aaron Lu <aaron.lu@intel.com> wrote:
>> Prior to 3.15, there was a race between zap_pte_range() and
>> page_mkclean() where writes to a page could be lost.  Dave Hansen
>> discovered by inspection that there is a similar race between
>> move_ptes() and  page_mkclean().
> 
> Ok, patch applied.
> 
> I'm not entirely happy with the force_flush vs need_flush games, and I
> really think this code should be updated to use the same "struct
> mmu_gather" that we use for the other TLB flushing cases (no need for
> the page freeing batching, but the tlb_flush_mmu_tlbonly() logic
> should be the same).

I see.

> 
> But I guess that's a bigger change, so that wouldn't be approriate for
> rc5 or stable back-porting anyway. But it would be lovely if somebody
> could look at that. Hint hint.

I'll work on it, thanks for the suggestion.

Regards,
Aaron

> 
> Hmm?
> 
>                Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
