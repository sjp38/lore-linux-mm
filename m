Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 1D1646B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 23:10:27 -0400 (EDT)
Message-ID: <52294758.7030801@cn.fujitsu.com>
Date: Fri, 06 Sep 2013 11:09:12 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/11] x86, mem-hotplug: Support initialize page tables
 from low to high.
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com> <1377596268-31552-11-git-send-email-tangchen@cn.fujitsu.com> <20130905133027.GA23038@hacker.(null)> <52293118.8080707@cn.fujitsu.com> <20130906021653.GA1062@hacker.(null)>
In-Reply-To: <20130906021653.GA1062@hacker.(null)>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi Wanpeng,

On 09/06/2013 10:16 AM, Wanpeng Li wrote:
......
>>>> +#ifdef CONFIG_MOVABLE_NODE
>>>> +	unsigned long kernel_end;
>>>> +
>>>> +	if (movablenode_enable_srat&&
>>>> +	    memblock.current_order == MEMBLOCK_ORDER_LOW_TO_HIGH) {
>>>
>>> I think memblock.current_order == MEMBLOCK_ORDER_LOW_TO_HIGH is always
>>> true if config MOVABLE_NODE and movablenode_enable_srat == true if PATCH
>>> 11/11 is applied.
>>
>> memblock.current_order == MEMBLOCK_ORDER_LOW_TO_HIGH is true here if
>> MOVABLE_NODE
>> is configured, and it will be reset after SRAT is parsed. But
>> movablenode_enable_srat
>> could only be true when users specify movablenode boot option in the
>> kernel commandline.
>
> You are right.
>
> I mean the change should be:
>
> +#ifdef CONFIG_MOVABLE_NODE
> +       unsigned long kernel_end;
> +
> +       if (movablenode_enable_srat) {
>
> The is unnecessary to check memblock.current_order since it is always true
> if movable_node is configured and movablenode_enable_srat is true.
>

But I think, memblock.current_order is set outside init_mem_mapping(). And
the path in the if statement could only be run when current order is from
low to high. So I think it is safe to check it here.

I prefer to keep it at least in the next version patch-set. If others also
think it is unnecessary, I'm OK with removing the checking. :)

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
