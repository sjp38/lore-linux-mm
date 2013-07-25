Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D847A6B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 23:47:31 -0400 (EDT)
Message-ID: <51F0A074.403@cn.fujitsu.com>
Date: Thu, 25 Jul 2013 11:50:12 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 17/21] page_alloc, mem-hotplug: Improve movablecore to
 {en|dis}able using SRAT.
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com> <1374220774-29974-18-git-send-email-tangchen@cn.fujitsu.com> <20130723210435.GV21100@mtj.dyndns.org> <20130723211119.GW21100@mtj.dyndns.org>
In-Reply-To: <20130723211119.GW21100@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 07/24/2013 05:11 AM, Tejun Heo wrote:
> On Tue, Jul 23, 2013 at 05:04:35PM -0400, Tejun Heo wrote:
>> On Fri, Jul 19, 2013 at 03:59:30PM +0800, Tang Chen wrote:
>> ...
>>> Users can specify "movablecore=acpi" in kernel commandline to enable this
>>> functionality. For those who don't use memory hotplug or who don't want
>>> to lose their NUMA performance, just don't specify anything. The kernel
>>> will work as before.
>>
>> The param name is pretty obscure and why would the user care where
>
> I mean, having movable zone is required for having any decent chance
> of memory hotplug and movable zone implies worse affinity for kernel
> data structures, so there's no point in distinguishing memory hotplug
> enable/disable and this, right?
>

Sorry, I don't quite get this.

By movable zone, do you mean movable node (which has ZONE_MOVABLE only) ?


movablecore boot option was used to specify the size of ZONE_MOVABLE. And
this patch-set aims to arrange ZONE_MOVABLE with SRAT info. So my original
thinking is to reuse movablecore.

Since you said above, I think we have two problems here:
1. Should not let users care about where the hotplug info comes from.
2. Should not distinguish movable node and memory hotplug, since for now,
    to use memory hotplug is to use movable node.

So how about something like "movablenode", just like "quiet" boot option.
If users specify "movablenode", then memblock will reserve hotpluggable
memory, and create movable nodes if any. If users specify nothing, then
the kernel acts as before.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
