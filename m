Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id DBFAF6B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 19:44:39 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id 29so2122511yhl.34
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 16:44:39 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id v1si3719116yhg.1.2013.12.13.16.44.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 16:44:38 -0800 (PST)
Message-ID: <52ABA9EC.5070100@ti.com>
Date: Fri, 13 Dec 2013 19:44:28 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 07/23] mm/memblock: switch to use NUMA_NO_NODE instead
 of MAX_NUMNODES
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com> <1386625856-12942-8-git-send-email-santosh.shilimkar@ti.com> <20131213212912.GL27070@htj.dyndns.org>
In-Reply-To: <20131213212912.GL27070@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Friday 13 December 2013 04:29 PM, Tejun Heo wrote:
> On Mon, Dec 09, 2013 at 04:50:40PM -0500, Santosh Shilimkar wrote:
>> +	if (nid == MAX_NUMNODES)
>> +		pr_warn_once("%s: Usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE instead\n",
>> +			     __func__);
> 
> Why not just use WARN_ONCE()?  We'd want to know who the caller is
> anyway.  Also, wouldn't something like the following simpler?
> 
> 	if (WARN_ONCE(nid == MAX_NUMNODES, blah blah))
> 		nid = NUMA_NO_NODE;
> 
Agree.

>> @@ -768,6 +773,11 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
>>  	struct memblock_type *rsv = &memblock.reserved;
>>  	int mi = *idx & 0xffffffff;
>>  	int ri = *idx >> 32;
>> +	bool check_node = (nid != NUMA_NO_NODE) && (nid != MAX_NUMNODES);
>> +
>> +	if (nid == MAX_NUMNODES)
>> +		pr_warn_once("%s: Usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE instead\n",
>> +			     __func__);
> 
> Ditto.
>
OK.

> 
> Reviwed-by: Tejun Heo <tj@kernel.org>
> 
Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
