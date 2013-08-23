Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id BFC386B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 17:08:07 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id wd6so1199873obb.33
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 14:08:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAD11hGxase=mk_pYEvtYyrHTWb=u5D4XX0PJT8Ah6owtPQSRxg@mail.gmail.com>
References: <20130821204041.GC2436@htj.dyndns.org>
	<1377124595.10300.594.camel@misato.fc.hp.com>
	<20130822033234.GA2413@htj.dyndns.org>
	<1377186729.10300.643.camel@misato.fc.hp.com>
	<20130822183130.GA3490@mtj.dyndns.org>
	<1377202292.10300.693.camel@misato.fc.hp.com>
	<20130822202158.GD3490@mtj.dyndns.org>
	<1377205598.10300.715.camel@misato.fc.hp.com>
	<20130822212111.GF3490@mtj.dyndns.org>
	<1377209861.10300.756.camel@misato.fc.hp.com>
	<20130823130440.GC10322@mtj.dyndns.org>
	<1377274448.10300.777.camel@misato.fc.hp.com>
	<521793BB.9080605@gmail.com>
	<CAE9FiQXZ610BrVaXoxY70NS3CaSku7mcVFx+x34-jpYUkG2rdQ@mail.gmail.com>
	<CAD11hGxase=mk_pYEvtYyrHTWb=u5D4XX0PJT8Ah6owtPQSRxg@mail.gmail.com>
Date: Fri, 23 Aug 2013 14:08:06 -0700
Message-ID: <CAE9FiQU0n++wSR2Xmv06DGGie0zemwrVQr9Ha7Qv+88DX3wbdA@mail.gmail.com>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chen tang <imtangchen@gmail.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Toshi Kani <toshi.kani@hp.com>, Tejun Heo <tj@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

> because we have found and mapped all the memory in the system at early time.
>
> But it is not easy to solve.
> 1. We still have to know how much memory and cpus the boot PXM has.
>     How could we know that ?  SRAT again ?

yes, need to parse numa info early, and only use RAM for PXM(X) at first.

> 2. The boot PXM could have little memory, and we meet the kexec and kdump
>     problem again.

could extend to have more PXM at first, like boot pxm mask.

> 3. I'm not quite sure is there any important benefit that the kernel
> initializes all
>     the memory at beginning ?
>
> And also, the memory hotplug schedule is very tough for us. We really want the
> movablenode functionality could be available soon. And this idea could
> be a long way to go. So I also think this would be the next step.

uh?
I already tried best to help. Even spent time to produce patchset
to separate acpi_override find/copy, and numa_info parse early
and put page tables on local nodes.

Let me know what else I could help.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
