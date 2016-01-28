Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 601AA6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:07:04 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wb13so10776697obb.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 11:07:04 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d71si11585385oih.12.2016.01.28.11.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 11:07:03 -0800 (PST)
Subject: Re: [LSF/MM ATTEND] Huge Page Futures
References: <56A580F8.4060301@oracle.com>
 <20160125110137.GB11541@node.shutemov.name> <56A62837.7010105@oracle.com>
 <56A90345.3020903@oracle.com>
 <alpine.LSU.2.11.1601280022040.4201@eggly.anvils>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56AA66CE.8080000@oracle.com>
Date: Thu, 28 Jan 2016 11:06:54 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1601280022040.4201@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 01/28/2016 12:49 AM, Hugh Dickins wrote:
> On Wed, 27 Jan 2016, Mike Kravetz wrote:
>> On 01/25/2016 05:50 AM, Mike Kravetz wrote:
>>> On 01/25/2016 03:01 AM, Kirill A. Shutemov wrote:
>>>> On Sun, Jan 24, 2016 at 05:57:12PM -0800, Mike Kravetz wrote:
>>>>> - Adding shared page table (PMD) support to DAX much like that which exists
>>>>>   for hugetlbfs
>>>>
>>>> Shared page tables for hugetlbfs is rather ugly hack.
>>>>
>>>> Do you have any thoughts how it's going to be implemented? It would be
>>>> nice to have some design overview or better proof-of-concept patch before
>>>> the summit to be able analyze implications for the kernel.
>>>>
>>>
>>> Good to know the hugetlbfs implementation is considered a hack.  I just
>>> started looking at this, and was going to use hugetlbfs as a starting
>>> point.  I'll reconsider that decision.
>>
>> Kirill, can you (or others) explain your reasons for saying the hugetlbfs
>> implementation is an ugly hack?  I do not have enough history/experience
>> with this to say what is most offensive.  I would be happy to start by
>> cleaning up issues with the current implementation.
> 
> I disagree that the hugetlbfs shared pagetables are an ugly hack.
> What they are is a dark backwater that very few people are aware of,
> which we therefore can very easily break or be broken by.
> 
> I have regretted bringing them into mm for that reason, and have
> thought that they're next in line for the axe, after those non-linear
> vmas which Kirill dispatched without tears last year.  But if you're
> intent on making more use of them, exposing them to the light of day
> is a fair alternative to consider.

It is interesting to note that at least one DB vendor (my employer) is
very aware of hugetlbfs shared pagetables, and takes advantage of them
in their DB architecture.  Their primary concern is the memory savings
that sharing provides.  I agree with you that very few people know
about them.  I didn't know they existed until informed by the DB team
and I looked at the code.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
