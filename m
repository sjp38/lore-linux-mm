Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id BA7D36B0032
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 17:21:18 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id bq6so627231qab.4
        for <linux-mm@kvack.org>; Thu, 22 Aug 2013 14:21:17 -0700 (PDT)
Date: Thu, 22 Aug 2013 17:21:11 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
Message-ID: <20130822212111.GF3490@mtj.dyndns.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377205598.10300.715.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello, Toshi.

On Thu, Aug 22, 2013 at 03:06:38PM -0600, Toshi Kani wrote:
> Since some node(s) won't be ejectable, this solution is reasonable as
> the first step.  I do not think it is a distraction.  I view your

But does this contribute to reaching the next step?  If so, how?
I can't see how and that's why I said this was a distraction.

> suggestion as a distraction of supporting local page tables, though.

Hmmm...

> Local page table and memory hotplug are two separate things.  That is,
> local page tables can be supported on all NUMA platforms without hotplug
> support.  Are you sure huge mapping will solve everything for all types
> of applications, and therefore local page tables won't be needed at all?

When you throw around terms like "all" and "at all", you can't reach
rational discussion about engineering trade-offs.  I was asking you
whether it was reasonable to do per-node page table when most machines
support huge page mappings which makes the whole thing rather
pointless.  Of course there will be some niche cases where this might
not be optimal but do you think that would be enough to justify the
added complexity and churn?  If you think so, can you please
elaborate?

> When someone changes the page table init code, who will test it with the
> special allocation code?

What are you worrying about?  Are you saying that allocating page
table towards top or bottom of memory would be more disruptive and
difficult to debug than pulling in ACPI init and SRAT information into
the process?  Am I missing something here?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
