Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id AB1BF6B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 13:14:24 -0400 (EDT)
Received: by obbeb7 with SMTP id eb7so75802278obb.3
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 10:14:24 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e7si8381716obf.19.2015.04.17.10.14.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 10:14:24 -0700 (PDT)
Message-ID: <55313F6A.4010506@oracle.com>
Date: Fri, 17 Apr 2015 10:14:18 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/4] hugetlbfs: add hugetlbfs_fallocate()
References: <00fc01d078e3$63428ec0$29c7ac40$@alibaba-inc.com> <010201d078e4$97cf82a0$c76e87e0$@alibaba-inc.com>
In-Reply-To: <010201d078e4$97cf82a0$c76e87e0$@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 04/17/2015 01:00 AM, Hillf Danton wrote:
>> +		clear_huge_page(page, addr, pages_per_huge_page(h));
>> +		__SetPageUptodate(page);
>> +		error = huge_add_to_page_cache(page, mapping, index);
>> +		if (error) {
>> +			put_page(page);
>> +			/* Keep going if we see an -EEXIST */
>> +			if (error != -EEXIST)
>> +				goto out;  /* FIXME, need to free? */
>> +		}
>> +
>> +		/*
>> +		 * page_put due to reference from alloc_huge_page()
>> +		 * unlock_page because locked by add_to_page_cache()
>> +		 */
>> +		put_page(page);
>
> Still needed if EEXIST?

Nope.  Good catch.

I'll fix this in the next version.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
