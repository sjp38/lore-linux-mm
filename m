Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 1B5756B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 23:57:41 -0400 (EDT)
Message-ID: <51F1F453.8060602@cn.fujitsu.com>
Date: Fri, 26 Jul 2013 12:00:19 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 18/21] x86, numa: Synchronize nid info in memblock.reserve
 with numa_meminfo.
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com> <1374220774-29974-19-git-send-email-tangchen@cn.fujitsu.com> <20130723212548.GZ21100@mtj.dyndns.org> <51F0A4F9.2060802@cn.fujitsu.com> <20130725150554.GC26107@mtj.dyndns.org>
In-Reply-To: <20130725150554.GC26107@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 07/25/2013 11:05 PM, Tejun Heo wrote:
> Hello, Tang.
>
> On Thu, Jul 25, 2013 at 12:09:29PM +0800, Tang Chen wrote:
>> And as in [patch 14/21], when reserving hotpluggable memory, we use
>> pxm. So my
>
> Which is kinda nasty.

Yes, will remove it.

>
>> idea was to do a nid sync in numa_init(). After this, memblock will
>> set nid when
>> it allocates memory.
>
> Sure, that's the only place we can set the numa node IDs but my point
> is that you don't need to add another interface.  Jet let
> memblock_set_node() handle both memblock.memory and .reserved ranges.
> That way, you can make memblock simpler to use and less error-prone.

Yes, I missed the isolation phase in memblock_set_node().
So followed.

>
>> If we want to let memblock_set_node() and alloc functions set nid on
>> the reserved
>> regions, we should setup nid<->  pxm mapping when we parst SRAT for
>> the first time.
>
> I don't follow why it has to be different.  Why do you need to do
> anything differently?  What am I missing here?

No, it was me who missed the isolation phase in memblock_set_node().

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
