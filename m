Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id A8AB36B0037
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 11:41:45 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so1597279pdj.29
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 08:41:44 -0700 (PDT)
Message-ID: <52090225.6070208@gmail.com>
Date: Mon, 12 Aug 2013 23:41:25 +0800
From: Tang Chen <imtangchen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <20130812145016.GI15892@htj.dyndns.org>
In-Reply-To: <20130812145016.GI15892@htj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, imtangchen@gmail.com

On 08/12/2013 10:50 PM, Tejun Heo wrote:
> Hello,
......
>
> I think it's in a much better shape than before but there still are a
> couple things bothering me.
>
> * Why can't it be opportunistic?  It's silly, for example, to fail
>    boot because ACPI tells the kernel that all memory is hotpluggable
>    especially as there'd be plenty of memory sitting around doing
>    nothing and failing to boot is one of the most grave failure mode.
>    The HOTPLUG flag can be advisory, right?  Try to allocate
>    !hotpluggable memory first, but if that fails, ignore it and
>    allocate from anywhere, much like the try_nid allocations.
>

Then there is no way to tell the users which memory is hotpluggable.

phys addr is not user friendly. For users, node or memory device is the
best. The firmware should arrange the hotpluggable ranges well.

In my opinion, maybe some application layer tools may use SRAT to show
the users which memory is hotpluggable. I just think both of the kernel
and the application layer should obey the same rule.

> * Similar to the point hpa raised.  If this can be made opportunistic,
>    do we need the strict reordering to discover things earlier?
>    Shouldn't it be possible to configure memblock to allocate close to
>    the kernel image until hotplug and numa information is available?
>    For most sane cases, the memory allocated will be contained in
>    non-hotpluggable node anyway and in case they aren't hotplug
>    wouldn't work but the system will boot and function perfectly fine.

So far as I know, the kernel image and related data can be loaded
anywhere, above 4GB. I just can't make any assumption.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
