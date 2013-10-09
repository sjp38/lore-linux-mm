Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EE6586B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 20:02:38 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so1820450pab.31
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 17:02:38 -0700 (PDT)
Message-ID: <1381363135.5429.138.camel@misato.fc.hp.com>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 09 Oct 2013 17:58:55 -0600
In-Reply-To: <20131009211136.GH5592@mtj.dyndns.org>
References: <524E2032.4020106@gmail.com> <524E2127.4090904@gmail.com>
	 <5251F9AB.6000203@zytor.com> <525442A4.9060709@gmail.com>
	 <20131009164449.GG22495@htj.dyndns.org> <52558EEF.4050009@gmail.com>
	 <20131009192040.GA5592@mtj.dyndns.org>
	 <1381352311.5429.115.camel@misato.fc.hp.com>
	 <20131009211136.GH5592@mtj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J .
 Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello Tejun,

On Wed, 2013-10-09 at 17:11 -0400, Tejun Heo wrote:
> On Wed, Oct 09, 2013 at 02:58:31PM -0600, Toshi Kani wrote:
> > Let's not assume that memory hotplug is always a niche feature for huge
> > & special systems.  It may be a niche to begin with, but it could be
> > supported on VMs, which allows anyone to use.  Vasilis has been working
> > on KVM to support memory hotplug.
> 
> I'm not saying hotplug will always be niche.

Great. :)

> I'm saying the approach
> we're currently taking is.  It seems fairly inflexible to hang the
> whole thing on NUMA nodes.  What does the planned kvm support do?
> Splitting SRAT nodes so that it can do both actual NUMA node
> distribution and hotplug granuliarity?  

I agree that using a node as the granularity is inflexible, but we have
to start from some point first, so that we can improve in future.  SRAT
may have multiple entries per a proximity and each of which can be set
to hotpluggable or not.  So, using SRAT does not limit us to the node
granularity.  The kernel however has limitations that zone type, etc,
are managed per a node basis.

> IIRC I asked a couple times
> what the long term plan was for this feature and there doesn't seem to
> be any road map for this thing to become a full solution.  Unless I
> misunderstood, this is more of "let's put out the fire as there
> already are (or gonna be) machines which can do it" kinda thing, which
> is fine too.  My point is that it doesn't make a lot of sense to
> change boot sequence invasively to accomodate that.

Well, there was a plan before, which considered to enhance it to a
memory device granularity at step 3.  But we had a major replan at step
1 per your suggestion.

https://lkml.org/lkml/2013/6/19/73

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
