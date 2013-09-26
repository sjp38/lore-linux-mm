Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id B7BC86B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 11:48:20 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so1285334pbc.7
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 08:48:20 -0700 (PDT)
Received: by mail-qe0-f41.google.com with SMTP id 1so931569qee.0
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 08:48:17 -0700 (PDT)
Date: Thu, 26 Sep 2013 11:48:13 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 4/6] x86/mem-hotplug: Support initialize page tables
 in bottom-up
Message-ID: <20130926154813.GA32391@mtj.dyndns.org>
References: <5241D897.1090905@gmail.com>
 <5241DA5B.8000909@gmail.com>
 <20130926144851.GF3482@htj.dyndns.org>
 <52445606.7030108@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52445606.7030108@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Thu, Sep 26, 2013 at 11:43:02PM +0800, Zhang Yanfei wrote:
> > As Yinghai pointed out in another thread, do we need to worry about
> > falling back to top-down?
> 
> I've explained to him. Nop, we don't need to worry about that. Because even
> the min_pfn_mapped becomes ISA_END_ADDRESS in the second call below, we won't
> allocate memory below the kernel because we have limited the allocation above
> the kernel.

Maybe I misunderstood but wasn't he worrying about there not being
enough space above kernel?  In that case, it'd automatically fall back
to top-down allocation anyway, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
