Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 701A06B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 10:35:46 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id i10so854464oag.16
        for <linux-mm@kvack.org>; Thu, 15 Aug 2013 07:35:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <520C947B.40407@cn.fujitsu.com>
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com>
	<20130812145016.GI15892@htj.dyndns.org>
	<5208FBBC.2080304@zytor.com>
	<20130812152343.GK15892@htj.dyndns.org>
	<52090D7F.6060600@gmail.com>
	<20130812164650.GN15892@htj.dyndns.org>
	<5209CEC1.8070908@cn.fujitsu.com>
	<520A02DE.1010908@cn.fujitsu.com>
	<CAE9FiQV2-OOvHZtPYSYNZz+DfhvL0e+h2HjMSW3DyqeXXvdJkA@mail.gmail.com>
	<520C947B.40407@cn.fujitsu.com>
Date: Thu, 15 Aug 2013 07:35:45 -0700
Message-ID: <CAE9FiQV=7NJrT=hTq77rEeXCuMuZLeW9VFUCOjhgrX0rNpbKXg@mail.gmail.com>
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Tejun Heo <tj@kernel.org>, Tang Chen <imtangchen@gmail.com>, Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "Luck, Tony (tony.luck@intel.com)" <tony.luck@intel.com>

On Thu, Aug 15, 2013 at 1:42 AM, Tang Chen <tangchen@cn.fujitsu.com> wrote:

> So if we want to allocate page tables near the kernelimage, we have to do
> the following:
>
> 1. Use BRK to map a range near kernel image, let's call it range X.
> 2. Calculate how much memory needed to map all the memory, let's say Y
> Bytes.
>    Use range X to map at least Y Bytes memory near kernel image.
> 3. Use the mapped memory to map all the rest memory.
>
> Does this sound OK to you guys ?

oh, no.
We just get rid of pre-calculate the buffer size for page tables.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
