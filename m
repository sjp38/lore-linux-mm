Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id DAB876B0032
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 18:19:11 -0400 (EDT)
Message-ID: <1377209861.10300.756.camel@misato.fc.hp.com>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 22 Aug 2013 16:17:41 -0600
In-Reply-To: <20130822212111.GF3490@mtj.dyndns.org>
References: <20130821195410.GA2436@htj.dyndns.org>
	 <1377116968.10300.514.camel@misato.fc.hp.com>
	 <20130821204041.GC2436@htj.dyndns.org>
	 <1377124595.10300.594.camel@misato.fc.hp.com>
	 <20130822033234.GA2413@htj.dyndns.org>
	 <1377186729.10300.643.camel@misato.fc.hp.com>
	 <20130822183130.GA3490@mtj.dyndns.org>
	 <1377202292.10300.693.camel@misato.fc.hp.com>
	 <20130822202158.GD3490@mtj.dyndns.org>
	 <1377205598.10300.715.camel@misato.fc.hp.com>
	 <20130822212111.GF3490@mtj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello Tejun,

On Thu, 2013-08-22 at 17:21 -0400, Tejun Heo wrote:
 :
> > Local page table and memory hotplug are two separate things.  That is,
> > local page tables can be supported on all NUMA platforms without hotplug
> > support.  Are you sure huge mapping will solve everything for all types
> > of applications, and therefore local page tables won't be needed at all?
> 
> When you throw around terms like "all" and "at all", you can't reach
> rational discussion about engineering trade-offs.  I was asking you
> whether it was reasonable to do per-node page table when most machines
> support huge page mappings which makes the whole thing rather
> pointless.  Of course there will be some niche cases where this might
> not be optimal but do you think that would be enough to justify the
> added complexity and churn?  If you think so, can you please
> elaborate?

I am relatively new to Linux, so I am not a good person to elaborate
this.  From my experience on other OS, huge pages helped for the kernel,
but did not necessarily help user applications.  It depended on
applications, which were not niche cases.  But Linux may be different,
so I asked since you seemed confident.  I'd appreciate if you can point
us some data that endorses your statement.

> > When someone changes the page table init code, who will test it with the
> > special allocation code?
> 
> What are you worrying about?  Are you saying that allocating page
> table towards top or bottom of memory would be more disruptive and
> difficult to debug than pulling in ACPI init and SRAT information into
> the process?  Am I missing something here?

My worry is that the code is unlikely tested with the special logic when
someone makes code changes to the page tables.  Such code can easily be
broken in future.

To answer your other question/email, I believe Tang's next step is to
support local page tables.  This is why we think pursing SRAT earlier is
the right direction.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
