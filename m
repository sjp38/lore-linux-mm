Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id C99F66B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 14:15:28 -0400 (EDT)
Received: by mail-vb0-f49.google.com with SMTP id w16so7908917vbb.36
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 11:15:27 -0700 (PDT)
Message-ID: <520BC950.1030806@gmail.com>
Date: Wed, 14 Aug 2013 14:15:44 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <20130812145016.GI15892@htj.dyndns.org> <52090225.6070208@gmail.com> <20130812154623.GL15892@htj.dyndns.org> <52090AF6.6020206@gmail.com> <20130812162247.GM15892@htj.dyndns.org> <520914D5.7080501@gmail.com> <20130812180758.GA8288@mtj.dyndns.org>
In-Reply-To: <20130812180758.GA8288@mtj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, kosaki.motohiro@gmail.com

(8/12/13 2:07 PM), Tejun Heo wrote:
> Hey,
>
> On Tue, Aug 13, 2013 at 01:01:09AM +0800, Tang Chen wrote:
>> Sorry for the misunderstanding.
>>
>> I was trying to answer your question: "Why can't the kenrel allocate
>> hotpluggable memory opportunistic ?".
>
> I've used the wrong word, I was meaning best-effort, which is the only
> thing we can do anyway given that we have no control over where the
> kernel image is linked in relation to NUMA nodes.
>
>> If the kernel has any opportunity to allocate hotpluggable memory in
>> SRAT, then the kernel should tell users which memory is hotpluggable.
>>
>> But in what way ?  I think node is the best for now. But a node could
>> have a lot of memory. If the kernel uses only a little memory, we will
>> lose the whole movable node, which I don't want to do.
>>
>> So, I don't want to allow the kenrel allocating hotpluggable memory
>> opportunistic.
>
> What I was saying was that the kernel should try !hotpluggable memory
> first then fall back to hotpluggable memory instead of failing boot as
> nothing really is worse than failing to boot.

I don't follow this. We need to think why memory hotplug is necessary.
Because system reboot is unacceptable on several critical services. Then,
if someone set wrong boot option, systems SHOULD fail to boot. At that time,
admin have a chance to fix their mistake. In the other hand, after running
production service, they have no chance to fix the mistake. In general, default
boot option should have a fallback and non-default option should not have a
fallback. That's a fundamental rule.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
