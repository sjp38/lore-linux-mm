Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 11D246B0034
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:27:33 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so4599672pdj.18
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:27:33 -0700 (PDT)
Received: by mail-qa0-f41.google.com with SMTP id ii20so2453541qab.0
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:27:31 -0700 (PDT)
Date: Tue, 24 Sep 2013 09:27:27 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/6] x86/mem-hotplug: Support initialize page tables
 bottom up
Message-ID: <20130924132727.GI2366@htj.dyndns.org>
References: <524162DA.30004@cn.fujitsu.com>
 <5241649B.3090302@cn.fujitsu.com>
 <20130924123340.GE2366@htj.dyndns.org>
 <52419264.3020409@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52419264.3020409@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

On Tue, Sep 24, 2013 at 09:23:48PM +0800, Zhang Yanfei wrote:
> > Hmm... so, this is kinda weird.  We're doing it in two chunks and
> > mapping memory between ISA_END_ADDRESS and kernel_end right on top of
> > ISA_END_ADDRESS?  Can't you give enough information to the mapping
> > function so that it can map everything on top of kernel_end in single
> > go?
> 
> You mean we should call memory_map_bottom_up like this:
> 
> memory_map_bottom_up(ISA_END_ADDRESS, end)
> 
> right?

But that wouldn't be ideal as we want the page tables above kernel
image and the above would allocate it above ISA_END_ADDRESS, right?
Maybe memory_map_bottom_up() should take extra parameters for where to
allocate page tables at separately from the mapping range and treat it
specially?  Would that make the function a lot more complex?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
