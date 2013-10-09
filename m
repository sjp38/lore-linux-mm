Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 47EAA6B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 17:02:21 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so1670581pab.1
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 14:02:20 -0700 (PDT)
Message-ID: <1381352311.5429.115.camel@misato.fc.hp.com>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 09 Oct 2013 14:58:31 -0600
In-Reply-To: <20131009192040.GA5592@mtj.dyndns.org>
References: <524E2032.4020106@gmail.com> <524E2127.4090904@gmail.com>
	 <5251F9AB.6000203@zytor.com> <525442A4.9060709@gmail.com>
	 <20131009164449.GG22495@htj.dyndns.org> <52558EEF.4050009@gmail.com>
	 <20131009192040.GA5592@mtj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J .
 Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Wed, 2013-10-09 at 15:20 -0400, Tejun Heo wrote:
> Hello,
> 
> On Thu, Oct 10, 2013 at 01:14:23AM +0800, Zhang Yanfei wrote:
> > >> You meant that the memory size is about few megs. But here, page tables
> > >> seems to be large enough in big memory machines, so that page tables will
> > > 
> > > Hmmm?  Even with 4k mappings and, say, 16Gigs of memory, it's still
> > > somewhere above 32MiB, right?  And, these physical mappings don't
> > > usually use 4k mappings to begin with.  Unless we're worrying about
> > > ISA DMA limit, I don't think it'd be problematic.
> > 
> > I think Peter meant very huge memory machines, say 2T memory? In the worst
> > case, this may need 2G memory for page tables, seems huge....
> 
> Realistically tho, why would people be using 4k mappings on 2T
> machines?  For the sake of argument, let's say 4k mappings are
> required for some weird reason, even then, doing SRAT parsing early
> doesn't necessarily solve the problem in itself.  It'd still need
> heuristics to avoid occupying too much of 32bit memory because it
> isn't difficult to imagine specific NUMA settings which would drive
> page table allocation into low address.
> 
> No matter what we do, there's no way around the fact that this whole
> effort is mostly an incomplete solution in its nature and that's why I
> think we better keep things isolated and simple.  It isn't a good idea
> to make structural changes to accomodate something which isn't and
> doesn't have much chance of becoming a full solution.  In addition,
> the problem itself is niche to begin with.

Let's not assume that memory hotplug is always a niche feature for huge
& special systems.  It may be a niche to begin with, but it could be
supported on VMs, which allows anyone to use.  Vasilis has been working
on KVM to support memory hotplug.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
