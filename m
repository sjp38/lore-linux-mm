Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 8FFDC6B0031
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 21:01:19 -0400 (EDT)
Message-ID: <5237A9B0.2070507@huawei.com>
Date: Tue, 17 Sep 2013 09:00:32 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mempolicy: use NUMA_NO_NODE
References: <5236FF32.60503@huawei.com> <5237695F.6010501@linux.vnet.ibm.com>
In-Reply-To: <5237695F.6010501@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh
 Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2013/9/17 4:26, Cody P Schafer wrote:

> 
>> @@ -1802,11 +1802,11 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
>>
>>   /*
>>    * Return the bit number of a random bit set in the nodemask.
>> - * (returns -1 if nodemask is empty)
>> + * (returns NUMA_NO_NOD if nodemask is empty)
> 
> s/NUMA_NO_NOD/NUMA_NO_NODE/

> 

Thanks, I will resent this.

>>    */
>>   int node_random(const nodemask_t *maskp)
>>   {
>> -    int w, bit = -1;
>> +    int w, bit = NUMA_NO_NODE;
>>
>>       w = nodes_weight(*maskp);
>>       if (w)
>>
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
