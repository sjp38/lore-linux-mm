Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id CFB416B0037
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 13:01:31 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so6997717pbc.17
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 10:01:31 -0700 (PDT)
Message-ID: <520914D5.7080501@gmail.com>
Date: Tue, 13 Aug 2013 01:01:09 +0800
From: Tang Chen <imtangchen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <20130812145016.GI15892@htj.dyndns.org> <52090225.6070208@gmail.com> <20130812154623.GL15892@htj.dyndns.org> <52090AF6.6020206@gmail.com> <20130812162247.GM15892@htj.dyndns.org>
In-Reply-To: <20130812162247.GM15892@htj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi tj,

On 08/13/2013 12:22 AM, Tejun Heo wrote:
> Hello, Tang.
>
> On Tue, Aug 13, 2013 at 12:19:02AM +0800, Tang Chen wrote:
>> The kernel can export info to users. The point is what kind of info.
>> Exporting phys addr is meaningless, of course. Now in /sys, we only
>> have memory_block and node. memory_block is only 128M on x86, and
>> hotplug a memory_block means nothing. So actually we only have node.
>>
>> So users want to hotplug a node is reasonable, I think. In the
>> beginning, we set the hotplug unit to a node. That is also why we
>> did the movable node.
>>
>> In summary, node hotplug is much meaningful and usable for users.
>> So it is the best that we can arrange a whole node to be movable
>> node, not opportunistic.
>
> Still not following.  Yeah, sure, you can tell the userland that node
> X is hotpluggable or not hotpluggable after boot is complete.  Why is
> that relevant?

Sorry for the misunderstanding.

I was trying to answer your question: "Why can't the kenrel allocate
hotpluggable memory opportunistic ?".

If the kernel has any opportunity to allocate hotpluggable memory in
SRAT, then the kernel should tell users which memory is hotpluggable.

But in what way ?  I think node is the best for now. But a node could
have a lot of memory. If the kernel uses only a little memory, we will
lose the whole movable node, which I don't want to do.

So, I don't want to allow the kenrel allocating hotpluggable memory
opportunistic.


>
>> I'm just thinking of a more extreme case. For example, if a machine
>> has only one node hotpluggable, and the kernel resides in that node.
>> Then the system has no hotpluggable node.
>
> Yeah, sure, then there's no way that node can be hotpluggable and the
> right thing to do is booting up the machine and informing the userland
> that memory is not hotpluggable.
>
>> If we can prevent the kernel from using hotpluggable memory, in such
>> a machine, users can still do memory hotplug.
>>
>> I wanted to do it as generic as possible. But yes, finding out the
>> nodes the kernel resides in and make it unhotpluggable can work.
>
> Short of being able to remap memory under the kernel, I don't think
> this can be very generic and as a compromise trying to keep as many
> hotpluggable nodes as possible doesn't sound too bad.

I think making one of the node hotpluggable is better. But OK, it is
no big deal. There won't be such machine in reality, I think. :)

Thanks. :)





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
