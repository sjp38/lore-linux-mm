Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id DFA996B0034
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 23:39:33 -0400 (EDT)
Message-ID: <520C4D24.40701@cn.fujitsu.com>
Date: Thu, 15 Aug 2013 11:38:12 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] memblock cleanup: Remove unnecessary check in memblock_find_in_range_node()
References: <1376536999-4562-1-git-send-email-tangchen@cn.fujitsu.com> <20130815032746.GC4439@htj.dyndns.org>
In-Reply-To: <20130815032746.GC4439@htj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, liwanp@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/15/2013 11:27 AM, Tejun Heo wrote:
> Hello, Tang.
>
> On Thu, Aug 15, 2013 at 11:23:19AM +0800, Tang Chen wrote:
>> Furthermore, we don't need to check "if (this_end<  size)" actually. Without
>> this confusing check, we only waste some loops. So this patch removes the
>> check.
>>
>> Signed-off-by: Tang Chen<tangchen@cn.fujitsu.com>
>> ---
>>   mm/memblock.c |    3 ---
>>   1 files changed, 0 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index a847bfe..e0c626e 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -114,9 +114,6 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>>   		this_start = clamp(this_start, start, end);
>>   		this_end = clamp(this_end, start, end);
>>
>> -		if (this_end<  size)
>> -			continue;
>> -
>>   		cand = round_down(this_end - size, align);
>>   		if (cand>= this_start)
>>   			return cand;
>
> Hmmm... maybe I'm missing something but are you sure?  "this_end -
> size" can underflow and "cand>= this_start" will be true incorrectly.
>

Oh, you are right... Please ignore this. I didn't read it carefully.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
