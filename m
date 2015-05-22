Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 32097829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 13:11:09 -0400 (EDT)
Received: by oihb142 with SMTP id b142so18566760oih.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 10:11:09 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m83si1700802oig.33.2015.05.22.10.11.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 10:11:08 -0700 (PDT)
Message-ID: <555F630D.4090706@oracle.com>
Date: Fri, 22 May 2015 10:10:37 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 PATCH 04/10] mm/hugetlb: expose hugetlb fault mutex for
 use by fallocate
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>	 <1432223264-4414-5-git-send-email-mike.kravetz@oracle.com> <1432314077.2185.4.camel@stgolabs.net>
In-Reply-To: <1432314077.2185.4.camel@stgolabs.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On 05/22/2015 10:01 AM, Davidlohr Bueso wrote:
> On Thu, 2015-05-21 at 08:47 -0700, Mike Kravetz wrote:
>> +/*
>> + * Interfaces to the fault mutex routines for use by hugetlbfs
>> + * fallocate code.  Faults must be synchronized with page adds or
>> + * deletes by fallocate.  fallocate only deals with shared mappings.
>> + */
>> +u32 hugetlb_fault_mutex_shared_hash(struct address_space *mapping, pgoff_t idx)
>> +{
>> +	return fault_mutex_hash(NULL, NULL, NULL, mapping, idx, 0);
>> +}
>> +
>> +void hugetlb_fault_mutex_lock(u32 hash)
>> +{
>> +	mutex_lock(&htlb_fault_mutex_table[hash]);
>> +}
>> +
>> +void hugetlb_fault_mutex_unlock(u32 hash)
>> +{
>> +	mutex_unlock(&htlb_fault_mutex_table[hash]);
>> +}+
>
> These should really be inlined -- maybe add them to hugetlb.h along with
> the mutex hashtable bits.

Thanks.  I'll figure out some way to inline them in the next version
of the patch set.

-- 
Mike Kravetz

>
> Thanks,
> Davidlohr
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
