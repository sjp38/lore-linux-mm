Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9526B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 11:50:22 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so1290848pbb.38
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 08:50:22 -0700 (PDT)
Received: by mail-qa0-f50.google.com with SMTP id j7so951442qaq.9
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 08:50:19 -0700 (PDT)
Date: Thu, 26 Sep 2013 11:50:15 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 2/6] memblock: Introduce bottom-up allocation mode
Message-ID: <20130926155015.GB32391@mtj.dyndns.org>
References: <5241D897.1090905@gmail.com>
 <5241D9A4.4080305@gmail.com>
 <20130926144516.GD3482@htj.dyndns.org>
 <524454BE.4030602@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524454BE.4030602@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Thu, Sep 26, 2013 at 11:37:34PM +0800, Zhang Yanfei wrote:
> >> +		WARN_ONCE(1, "memblock: Failed to allocate memory in bottom up "
> >> +			"direction. Now try top down direction.\n");
> >> +	}
> > 
> > You and I would know what was going on and what the consequence of the
> > failure may be but the above warning message is kinda useless to a
> > user / admin, right?  It doesn't really say anything meaningful.
> > 
> 
> Hmmmm.. May be something like this:
> 
> WARN_ONCE(1, "Failed to allocated memory above the kernel in bottom-up,"
>           "so try to allocate memory below the kernel.");

How about something like "memblock: bottom-up allocation failed,
memory hotunplug may be affected\n".

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
