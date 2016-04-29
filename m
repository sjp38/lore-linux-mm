Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 00AA86B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 14:09:40 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id dx6so181777694pad.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 11:09:39 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id q64si17542598pfb.1.2016.04.29.11.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 11:09:38 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id y69so51050374pfb.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 11:09:38 -0700 (PDT)
Subject: Re: [PATCH] mm: move huge_pmd_set_accessed out of huge_memory.c
References: <1461176698-9714-1-git-send-email-yang.shi@linaro.org>
 <5717EDDB.1060704@linaro.org> <20160421073050.GA32611@node.shutemov.name>
 <57195A87.4050408@linaro.org> <20160422094815.GB7336@node.shutemov.name>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <0357941c-d7ce-3ba9-c24f-9d2599429a8a@linaro.org>
Date: Fri, 29 Apr 2016 11:09:36 -0700
MIME-Version: 1.0
In-Reply-To: <20160422094815.GB7336@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, hughd@google.com, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 4/22/2016 2:48 AM, Kirill A. Shutemov wrote:
> On Thu, Apr 21, 2016 at 03:56:07PM -0700, Shi, Yang wrote:
>> On 4/21/2016 12:30 AM, Kirill A. Shutemov wrote:
>>> On Wed, Apr 20, 2016 at 02:00:11PM -0700, Shi, Yang wrote:
>>>> Hi folks,
>>>>
>>>> I didn't realize pmd_* functions are protected by
>>>> CONFIG_TRANSPARENT_HUGEPAGE on the most architectures before I made this
>>>> change.
>>>>
>>>> Before I fix all the affected architectures code, I want to check if you
>>>> guys think this change is worth or not?
>>>>
>>>> Thanks,
>>>> Yang
>>>>
>>>> On 4/20/2016 11:24 AM, Yang Shi wrote:
>>>>> huge_pmd_set_accessed is only called by __handle_mm_fault from memory.c,
>>>>> move the definition to memory.c and make it static like create_huge_pmd and
>>>>> wp_huge_pmd.
>>>>>
>>>>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>>>
>>> On pte side we have the same functionality open-coded. Should we do the
>>> same for pmd? Or change pte side the same way?
>>
>> Sorry, I don't quite understand you. Do you mean pte_* functions?
>
> See handle_pte_fault(), we do the same for pte there what
> huge_pmd_set_accessed() does for pmd.

Thanks for directing to this code.

>
> I think we should be consistent here: either both are abstructed into
> functions or both open-coded.

I'm supposed functions sound better. However, do_wp_page has to be 
called with pte lock acquired. So, the abstracted function has to call it.

Thanks,
Yang


>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
