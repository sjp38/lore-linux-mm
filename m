Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id ABEB66B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 17:32:21 -0400 (EDT)
Received: by mail-ye0-f170.google.com with SMTP id q3so2674414yen.15
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 14:32:20 -0700 (PDT)
Date: Tue, 23 Jul 2013 17:32:12 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 14/21] x86, acpi, numa: Reserve hotpluggable memory at
 early time.
Message-ID: <20130723213212.GA21100@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-15-git-send-email-tangchen@cn.fujitsu.com>
 <20130723205557.GS21100@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130723205557.GS21100@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Tue, Jul 23, 2013 at 04:55:57PM -0400, Tejun Heo wrote:
> On Fri, Jul 19, 2013 at 03:59:27PM +0800, Tang Chen wrote:
> > +		/*
> > +		 * In such an early time, we don't have nid. We specify pxm
> > +		 * instead of MAX_NUMNODES to prevent memblock merging regions
> > +		 * on different nodes. And later modify pxm to nid when nid is
> > +		 * mapped so that we can arrange ZONE_MOVABLE on different
> > +		 * nodes.
> > +		 */
> > +		memblock_reserve_hotpluggable(base_address, length, pxm);
> 
> This is rather hacky.  Why not just introduce MEMBLOCK_NO_MERGE flag?

Also, if memblock is gonna know about hotplug memory, why not just let
it control its allocation too instead of blocking it by reserving it
from outside?  These are all pretty general memory hotplug logic which
doesn't have much to do with acpi and I think too much is implemented
on the acpi side.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
