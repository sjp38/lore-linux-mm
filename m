Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id A24F66B0254
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:50:51 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id ba1so117236288obb.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 05:50:51 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q9si17358498oih.89.2016.01.25.05.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 05:50:50 -0800 (PST)
Subject: Re: [LSF/MM ATTEND] Huge Page Futures
References: <56A580F8.4060301@oracle.com>
 <20160125110137.GB11541@node.shutemov.name>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56A62837.7010105@oracle.com>
Date: Mon, 25 Jan 2016 05:50:47 -0800
MIME-Version: 1.0
In-Reply-To: <20160125110137.GB11541@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 01/25/2016 03:01 AM, Kirill A. Shutemov wrote:
> On Sun, Jan 24, 2016 at 05:57:12PM -0800, Mike Kravetz wrote:
>> In a search of the archives, it appears huge page support in one form or
>> another has been a discussion topic in almost every LSF/MM gathering. Based
>> on patches submitted this past year, huge pages is still an area of active
>> development.  And, it appears this level of activity will  continue in the
>> coming year.
>>
>> I propose a "Huge Page Futures" session to discuss large works in progress
>> as well as work people are considering for 2016.  Areas of discussion would
>> minimally include:
>>
>> - Krill Shutemov's THP new refcounting code and the push for huge page
>>   support in the page cache.
> 
> s/Krill/Kirill/ :]

Sorry!

> 
> I work on huge pages in tmpfs first and will look on huge pages for real
> filesystems later.
> 
>>
>> - Matt Wilcox's huge page support in DAX enabled filesystems, but perhaps
>>   more interesting is the desire for supporting PUD pages.  This seems to
>>   beg the question of supporting transparent PUD pages elsewhere.
>>
>> - Other suggestions?
>>
>> My interest in attending also revolves around huge pages.  This past year
>> I have added functionality to hugetlbfs.  hugetlbfs is not dead, and is
>> very much in use by some DB implementations.  Proposed future work I will
>> be attempting includes:
>> - Adding userfaultfd support to hugetlbfs
>> - Adding shared page table (PMD) support to DAX much like that which exists
>>   for hugetlbfs
> 
> Shared page tables for hugetlbfs is rather ugly hack.
> 
> Do you have any thoughts how it's going to be implemented? It would be
> nice to have some design overview or better proof-of-concept patch before
> the summit to be able analyze implications for the kernel.
> 

Good to know the hugetlbfs implementation is considered a hack.  I just
started looking at this, and was going to use hugetlbfs as a starting
point.  I'll reconsider that decision.

BTW, this request comes from the same DB people taking advantage of shared
page tables today.  This will be as important (if not more) with the larger
sizes of pmem.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
