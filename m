Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7DEFE6B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:35:25 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so2786222pdj.3
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 08:35:25 -0700 (PDT)
Received: by mail-qe0-f47.google.com with SMTP id b4so2056942qen.20
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 08:35:22 -0700 (PDT)
Date: Thu, 10 Oct 2013 11:35:18 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
Message-ID: <20131010153518.GB13276@htj.dyndns.org>
References: <5251F9AB.6000203@zytor.com>
 <525442A4.9060709@gmail.com>
 <20131009164449.GG22495@htj.dyndns.org>
 <52558EEF.4050009@gmail.com>
 <20131009192040.GA5592@mtj.dyndns.org>
 <1381352311.5429.115.camel@misato.fc.hp.com>
 <20131009211136.GH5592@mtj.dyndns.org>
 <1381363135.5429.138.camel@misato.fc.hp.com>
 <20131010010029.GA10900@mtj.dyndns.org>
 <1381415809.24268.40.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381415809.24268.40.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "imtangchen@gmail.com" <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello,

On Thu, Oct 10, 2013 at 08:36:49AM -0600, Toshi Kani wrote:
> >  "3. Improve memory hotplug to support local device pagetable."
> > 
> > How can the above possibly be considered as a plan for finer
> > granularity?  Forget about the "how" part.  The stated goal doesn't
> > even mention finer granularity.  
> 
> The word "device" above refers memory device level granularity.  

That's a lot of reading inbetween the words.

> > Are firmware writers gonna be
> > required to split SRAT entries into multiple sub-nodes to support it?
> 
> Yes, and that's part of the ACPI spec.  That's not something the OS
> requests to do.  If a memory range has different attribute, firmware has
> to put it in a separate entry.

I was referring to having to segment a contiguous hotplug memory area
further to support finer granularity.  This is represented by separate
mem devices rather than segmented SRAT entries, right?  Hmmm... so we
should parse device nodes before setting up page tables?

> SRAT and _EJ0 method are the only interfaces that define ejectability in
> the standard spec.  Are you suggesting us to change the e820 spec or not
> to comply with the spec?  I do not think such approaches work.    

It's slower but standards get revised and updated over time.  Have no
idea whether there'd be a sane way to do that for e820 tho.

> I think memory hotplug was originally implemented on ia64 with the node
> granularity.  I share your concerns, but that's been done a long time
> ago.  It's too late to complain the past.  This SRAT work is not
> introducing such restriction.

We're going round and round.  You're saying that using SRAT isn't
worse than what came before while failing to illustrate how committing
to invasive changes would eventually lead to something better.  "it
isn't worse" isn't much of an argument.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
