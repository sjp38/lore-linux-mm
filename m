Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id F30AD6B0069
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 11:29:25 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id q3so41091583qtf.4
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:29:25 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f72si3981820qka.229.2017.01.13.08.29.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 08:29:25 -0800 (PST)
Subject: Re: [patch v2 linux-next] userfaultfd: hugetlbfs: unmap the correct
 pointer
References: <20170112193327.GB8558@dhcp22.suse.cz>
 <20170113082608.GA3548@mwanda> <20170113084044.GC25212@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <90d5f4a9-9a87-407d-18dc-246c6cea151f@oracle.com>
Date: Fri, 13 Jan 2017 08:29:14 -0800
MIME-Version: 1.0
In-Reply-To: <20170113084044.GC25212@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On 01/13/2017 12:40 AM, Michal Hocko wrote:
> On Fri 13-01-17 11:26:08, Dan Carpenter wrote:
>> kunmap_atomic() and kunmap() take different pointers.  People often get
>> these mixed up.
>>
>> Fixes: 16374db2e9a0 ("userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing")
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks for catching this!

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

> 
>> ---
>> v2: I was also unmapping the wrong pointer because I had a typo.
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 6012a05..aca8ef6 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -4172,7 +4172,7 @@ long copy_huge_page_from_user(struct page *dst_page,
>>  				(const void __user *)(src + i * PAGE_SIZE),
>>  				PAGE_SIZE);
>>  		if (allow_pagefault)
>> -			kunmap(page_kaddr);
>> +			kunmap(page_kaddr + i);
>>  		else
>>  			kunmap_atomic(page_kaddr);
>>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
