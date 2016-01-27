Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id E0C7E6B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 12:50:01 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id zv1so13691081obb.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:50:01 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id h7si4247331obf.1.2016.01.27.09.50.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 09:50:01 -0800 (PST)
Subject: Re: [LSF/MM ATTEND] Huge Page Futures
References: <56A580F8.4060301@oracle.com>
 <20160125110137.GB11541@node.shutemov.name> <56A62837.7010105@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56A90345.3020903@oracle.com>
Date: Wed, 27 Jan 2016 09:49:57 -0800
MIME-Version: 1.0
In-Reply-To: <56A62837.7010105@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 01/25/2016 05:50 AM, Mike Kravetz wrote:
> On 01/25/2016 03:01 AM, Kirill A. Shutemov wrote:
>> On Sun, Jan 24, 2016 at 05:57:12PM -0800, Mike Kravetz wrote:
>>> In a search of the archives, it appears huge page support in one form or
>>> another has been a discussion topic in almost every LSF/MM gathering. Based
>>> on patches submitted this past year, huge pages is still an area of active
>>> development.  And, it appears this level of activity will  continue in the
>>> coming year.
>>>
>>> I propose a "Huge Page Futures" session to discuss large works in progress
>>> as well as work people are considering for 2016.  Areas of discussion would
>>> minimally include:
>>>
>>> - Krill Shutemov's THP new refcounting code and the push for huge page
>>>   support in the page cache.
>>
>> s/Krill/Kirill/ :]
> 
> Sorry!
> 
>>
>> I work on huge pages in tmpfs first and will look on huge pages for real
>> filesystems later.
>>
>>>
>>> - Matt Wilcox's huge page support in DAX enabled filesystems, but perhaps
>>>   more interesting is the desire for supporting PUD pages.  This seems to
>>>   beg the question of supporting transparent PUD pages elsewhere.
>>>
>>> - Other suggestions?
>>>
>>> My interest in attending also revolves around huge pages.  This past year
>>> I have added functionality to hugetlbfs.  hugetlbfs is not dead, and is
>>> very much in use by some DB implementations.  Proposed future work I will
>>> be attempting includes:
>>> - Adding userfaultfd support to hugetlbfs
>>> - Adding shared page table (PMD) support to DAX much like that which exists
>>>   for hugetlbfs
>>
>> Shared page tables for hugetlbfs is rather ugly hack.
>>
>> Do you have any thoughts how it's going to be implemented? It would be
>> nice to have some design overview or better proof-of-concept patch before
>> the summit to be able analyze implications for the kernel.
>>
> 
> Good to know the hugetlbfs implementation is considered a hack.  I just
> started looking at this, and was going to use hugetlbfs as a starting
> point.  I'll reconsider that decision.

Kirill, can you (or others) explain your reasons for saying the hugetlbfs
implementation is an ugly hack?  I do not have enough history/experience
with this to say what is most offensive.  I would be happy to start by
cleaning up issues with the current implementation.

If we do shared page tables for DAX, it makes sense that it and hugetlbfs
should be similar (or common) if possible.

-- 
Mike Kravetz

> 
> BTW, this request comes from the same DB people taking advantage of shared
> page tables today.  This will be as important (if not more) with the larger
> sizes of pmem.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
