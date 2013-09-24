Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7B23D6B0037
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:39:15 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so3692698pad.2
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:39:15 -0700 (PDT)
Received: by mail-qc0-f172.google.com with SMTP id l13so3101901qcy.31
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:39:12 -0700 (PDT)
Date: Tue, 24 Sep 2013 09:39:08 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/6] x86/mem-hotplug: Support initialize page tables
 bottom up
Message-ID: <20130924133908.GJ2366@htj.dyndns.org>
References: <524162DA.30004@cn.fujitsu.com>
 <5241649B.3090302@cn.fujitsu.com>
 <20130924123340.GE2366@htj.dyndns.org>
 <52419264.3020409@gmail.com>
 <20130924132727.GI2366@htj.dyndns.org>
 <524194F6.4000101@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524194F6.4000101@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com

Hello,

On Tue, Sep 24, 2013 at 09:34:46PM +0800, Zhang Yanfei wrote:
> > But that wouldn't be ideal as we want the page tables above kernel
> > image and the above would allocate it above ISA_END_ADDRESS, right?
> 
> The original idea is we will allocate everything above the kernel. So
> the pagetables for [ISA_END_ADDRESS, kernel_end) will be also located
> above the kernel.

I'm a bit confused why we need two separate calls then.  What's the
difference from calling with the whole range?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
