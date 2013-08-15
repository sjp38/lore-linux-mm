Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id D441E6B0034
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 19:49:42 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 16 Aug 2013 09:32:57 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C6F7D2BB0054
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 09:49:36 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7FNXaeZ49348686
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 09:33:36 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7FNnZd8008720
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 09:49:35 +1000
Date: Fri, 16 Aug 2013 07:49:33 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] mm/vmalloc: use wrapper function get_vm_area_size to
 caculate size of vm area
Message-ID: <20130815234933.GB9879@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1376526703-2081-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1376526703-2081-4-git-send-email-liwanp@linux.vnet.ibm.com>
 <520D18F7.5000801@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520D18F7.5000801@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 15, 2013 at 11:07:51AM -0700, Dave Hansen wrote:
>On 08/14/2013 05:31 PM, Wanpeng Li wrote:
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 93d3182..553368c 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1553,7 +1553,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>>  	unsigned int nr_pages, array_size, i;
>>  	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
>>  
>> -	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
>> +	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
>>  	array_size = (nr_pages * sizeof(struct page *));
>
>I guess this is fine, but I do see this same kind of use in a couple of
>other spots in the kernel.  Was there a reason for doing this in this
>one spot but ignoring the others?

I will figure out all of them in next version, thanks for your review.

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
