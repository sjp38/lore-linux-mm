Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3545C6B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 12:40:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so29329327pfa.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 09:40:09 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id fq10si33876729pac.8.2016.06.07.09.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 09:40:08 -0700 (PDT)
Subject: Re: [RFC PATCH 3/6] mm/userfaultfd: add __mcopy_atomic_hugetlb for
 huge page UFFDIO_COPY
References: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
 <1465235131-6112-4-git-send-email-mike.kravetz@oracle.com>
 <01ad01d1c085$b61fdd60$225f9820$@alibaba-inc.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <279444f1-bfaa-d730-1cde-38552d3c4610@oracle.com>
Date: Tue, 7 Jun 2016 09:35:00 -0700
MIME-Version: 1.0
In-Reply-To: <01ad01d1c085$b61fdd60$225f9820$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Hugh Dickins' <hughd@google.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Michal Hocko' <mhocko@suse.com>, 'Andrew Morton' <akpm@linux-foundation.org>

On 06/06/2016 11:27 PM, Hillf Danton wrote:
>> @@ -182,6 +354,13 @@ retry:
>>  		goto out_unlock;
>>
>>  	/*
>> +	 * If this is a HUGETLB vma, pass off to appropriate routine
>> +	 */
>> +	if (dst_vma->vm_flags & VM_HUGETLB)
> 
> Use is_vm_hugetlb_page()?
> And in cases in subsequent patches?
> 
> Hillf

Yes, that would be better.  Thanks.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
