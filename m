Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC346B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 20:21:56 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id wo20so35405848obc.7
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 17:21:56 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id jg1si7202153obc.107.2015.03.02.17.21.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 17:21:55 -0800 (PST)
Message-ID: <54F50C73.9000401@oracle.com>
Date: Mon, 02 Mar 2015 17:20:51 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] hugetlbfs: add reserved mount fields to subpool structure
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>	<1425077893-18366-3-git-send-email-mike.kravetz@oracle.com> <20150302151018.ce35298f22d04d6d0296e53c@linux-foundation.org>
In-Reply-To: <20150302151018.ce35298f22d04d6d0296e53c@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/02/2015 03:10 PM, Andrew Morton wrote:
> On Fri, 27 Feb 2015 14:58:10 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
>> Add a boolean to the subpool structure to indicate that the pages for
>> subpool have been reserved.  The hstate pointer in the subpool is
>> convienient to have when it comes time to unreserve the pages.
>> subool_reserved() is a handy way to check if reserved and take into
>> account a NULL subpool.
>>
>> ...
>>
>> @@ -38,6 +40,10 @@ extern int hugetlb_max_hstate __read_mostly;
>>   #define for_each_hstate(h) \
>>   	for ((h) = hstates; (h) < &hstates[hugetlb_max_hstate]; (h)++)
>>
>> +static inline bool subpool_reserved(struct hugepage_subpool *spool)
>> +{
>> +	return spool && spool->reserved;
>> +}
>
> "subpool_reserved" is not a good identifier.
>
>>   struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
>>   void hugepage_put_subpool(struct hugepage_subpool *spool);
>
> See what they did?

Got it. Thanks. hugepage_subpool_reserved

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
