Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 709B66B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 14:22:05 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id d10so7877972vea.5
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 11:22:04 -0700 (PDT)
Message-ID: <520BCADE.2040109@gmail.com>
Date: Wed, 14 Aug 2013 14:22:22 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <20130812145016.GI15892@htj.dyndns.org> <52090225.6070208@gmail.com> <20130812154623.GL15892@htj.dyndns.org> <52090AF6.6020206@gmail.com> <20130812162247.GM15892@htj.dyndns.org> <520914D5.7080501@gmail.com> <52091A10.4030501@zytor.com>
In-Reply-To: <52091A10.4030501@zytor.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Tang Chen <imtangchen@gmail.com>, Tejun Heo <tj@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, kosaki.motohiro@gmail.com

(8/12/13 1:23 PM), H. Peter Anvin wrote:
> On 08/12/2013 10:01 AM, Tang Chen wrote:
>>>
>>>> I'm just thinking of a more extreme case. For example, if a machine
>>>> has only one node hotpluggable, and the kernel resides in that node.
>>>> Then the system has no hotpluggable node.
>>>
>>> Yeah, sure, then there's no way that node can be hotpluggable and the
>>> right thing to do is booting up the machine and informing the userland
>>> that memory is not hotpluggable.
>>>
>>>> If we can prevent the kernel from using hotpluggable memory, in such
>>>> a machine, users can still do memory hotplug.
>>>>
>>>> I wanted to do it as generic as possible. But yes, finding out the
>>>> nodes the kernel resides in and make it unhotpluggable can work.
>>>
>>> Short of being able to remap memory under the kernel, I don't think
>>> this can be very generic and as a compromise trying to keep as many
>>> hotpluggable nodes as possible doesn't sound too bad.
>>
>> I think making one of the node hotpluggable is better. But OK, it is
>> no big deal. There won't be such machine in reality, I think. :)
>>
>
> The user may very well have configured a system with mirrored memory for
> the kernel node as that will be non-hotpluggable, but not for the
> others.  One can wonder how much that actually buys in real life, but
> still...

Note. Such system is much cheaper than full memory mirroring system. That's
one of reason why server vendors are interesting in hot plugging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
