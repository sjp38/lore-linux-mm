Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 997EC828E8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 18:56:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so175424826pfb.0
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 15:56:10 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id q14si3634712par.57.2016.04.21.15.56.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 15:56:09 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id fs9so33366587pac.2
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 15:56:09 -0700 (PDT)
Subject: Re: [PATCH] mm: move huge_pmd_set_accessed out of huge_memory.c
References: <1461176698-9714-1-git-send-email-yang.shi@linaro.org>
 <5717EDDB.1060704@linaro.org> <20160421073050.GA32611@node.shutemov.name>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <57195A87.4050408@linaro.org>
Date: Thu, 21 Apr 2016 15:56:07 -0700
MIME-Version: 1.0
In-Reply-To: <20160421073050.GA32611@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, hughd@google.com, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 4/21/2016 12:30 AM, Kirill A. Shutemov wrote:
> On Wed, Apr 20, 2016 at 02:00:11PM -0700, Shi, Yang wrote:
>> Hi folks,
>>
>> I didn't realize pmd_* functions are protected by
>> CONFIG_TRANSPARENT_HUGEPAGE on the most architectures before I made this
>> change.
>>
>> Before I fix all the affected architectures code, I want to check if you
>> guys think this change is worth or not?
>>
>> Thanks,
>> Yang
>>
>> On 4/20/2016 11:24 AM, Yang Shi wrote:
>>> huge_pmd_set_accessed is only called by __handle_mm_fault from memory.c,
>>> move the definition to memory.c and make it static like create_huge_pmd and
>>> wp_huge_pmd.
>>>
>>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>
> On pte side we have the same functionality open-coded. Should we do the
> same for pmd? Or change pte side the same way?

Sorry, I don't quite understand you. Do you mean pte_* functions?

Thanks,
Yang

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
