Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 810296B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:28:41 -0500 (EST)
Received: by mail-io0-f176.google.com with SMTP id g73so66652349ioe.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 11:28:41 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id sa7si6589852igb.13.2016.01.28.11.28.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 11:28:40 -0800 (PST)
Subject: Re: [LSF/MM ATTEND] Huge Page Futures
References: <56A580F8.4060301@oracle.com> <87bn85ycbh.fsf@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56AA6BE1.2050809@oracle.com>
Date: Thu, 28 Jan 2016 11:28:33 -0800
MIME-Version: 1.0
In-Reply-To: <87bn85ycbh.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 01/28/2016 07:05 AM, Aneesh Kumar K.V wrote:
> Mike Kravetz <mike.kravetz@oracle.com> writes:
> 
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
> I am also interested in this discussion. We had some nice challenge
> w.r.t to powerpc implementation of THP.
> 
>>
>> - Matt Wilcox's huge page support in DAX enabled filesystems, but perhaps
>>   more interesting is the desire for supporting PUD pages.  This seems to
>>   beg the question of supporting transparent PUD pages elsewhere.
>>
> 
> I am also looking at switching powerpc hugetlbfs to GENERAL_HUGETLB. To
> support 16GB pages I would need hugepage at PUD/PGD. Can you elaborate
> why supporting huge PUD page is a challenge ?

For hugetlbfs it should not be an issue.  However, page fault handling for
hugetlbfs is already a special case today.  Is that what you were asking?

Matt's work adds THP for PUD sized huge pages to DAX mappings.  The thought
that popped into my head is "Does it make sense to try and expand THP for
PUD sized pages elsewhere?".  Perhaps that is nonsense and a silly question
to ask.

-- 
Mike Kravetz

> 
> -aneesh
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
