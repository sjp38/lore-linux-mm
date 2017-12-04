Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4860B6B0253
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 19:51:17 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i7so10045987pgq.7
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 16:51:17 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id a12si9305464pfl.63.2017.12.03.16.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Dec 2017 16:51:16 -0800 (PST)
Subject: Re: [patch 04/15] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
References: <5a2082fa.bXLNoQ4bvY4J0ImP%akpm@linux-foundation.org>
 <238af2fe-e8c2-5fe5-aa5b-1361e334058b@suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <35d916b1-5cce-6bab-e4ca-351a4034c4f6@huawei.com>
Date: Mon, 4 Dec 2017 08:49:53 +0800
MIME-Version: 1.0
In-Reply-To: <238af2fe-e8c2-5fe5-aa5b-1361e334058b@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@linux.intel.com, cl@linux.com, mingo@kernel.org, n-horiguchi@ah.jp.nec.com, rientjes@google.com, salls@cs.ucsb.edu, tanxiaojun@huawei.com

Hi Vlastimil,

On 2017/12/1 23:20, Vlastimil Babka wrote:
> On 11/30/2017 11:15 PM, akpm@linux-foundation.org wrote:
>> From: Yisheng Xie <xieyisheng1@huawei.com>
>> Subject: mm/mempolicy: add nodes_empty check in SYSC_migrate_pages
>>
>> As in manpage of migrate_pages, the errno should be set to EINVAL when
>> none of the node IDs specified by new_nodes are on-line and allowed by the
>> process's current cpuset context, or none of the specified nodes contain
>> memory.  However, when test by following case:
>>
>> 	new_nodes = 0;
>> 	old_nodes = 0xf;
>> 	ret = migrate_pages(pid, old_nodes, new_nodes, MAX);
>>
>> The ret will be 0 and no errno is set.  As the new_nodes is empty, we
>> should expect EINVAL as documented.
>>
>> To fix the case like above, this patch check whether target nodes AND
>> current task_nodes is empty, and then check whether AND
>> node_states[N_MEMORY] is empty.
>>
>> Link: http://lkml.kernel.org/r/1510882624-44342-4-git-send-email-xieyisheng1@huawei.com
>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
>> Cc: Andi Kleen <ak@linux.intel.com>
>> Cc: Chris Salls <salls@cs.ucsb.edu>
>> Cc: Christopher Lameter <cl@linux.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Tan Xiaojun <tanxiaojun@huawei.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> My previous concerns here were a mistake as I explained in my reply to
> v4. So you can add
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks
Yisheng Xie

> 
> and proceed with the series. Thanks.
> 
>> ---
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
