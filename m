Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id A75746B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 14:08:04 -0400 (EDT)
Received: by mail-qe0-f44.google.com with SMTP id 6so3825395qeb.3
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 11:08:03 -0700 (PDT)
Date: Mon, 12 Aug 2013 14:07:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
Message-ID: <20130812180758.GA8288@mtj.dyndns.org>
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130812145016.GI15892@htj.dyndns.org>
 <52090225.6070208@gmail.com>
 <20130812154623.GL15892@htj.dyndns.org>
 <52090AF6.6020206@gmail.com>
 <20130812162247.GM15892@htj.dyndns.org>
 <520914D5.7080501@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520914D5.7080501@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <imtangchen@gmail.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hey,

On Tue, Aug 13, 2013 at 01:01:09AM +0800, Tang Chen wrote:
> Sorry for the misunderstanding.
> 
> I was trying to answer your question: "Why can't the kenrel allocate
> hotpluggable memory opportunistic ?".

I've used the wrong word, I was meaning best-effort, which is the only
thing we can do anyway given that we have no control over where the
kernel image is linked in relation to NUMA nodes.

> If the kernel has any opportunity to allocate hotpluggable memory in
> SRAT, then the kernel should tell users which memory is hotpluggable.
> 
> But in what way ?  I think node is the best for now. But a node could
> have a lot of memory. If the kernel uses only a little memory, we will
> lose the whole movable node, which I don't want to do.
> 
> So, I don't want to allow the kenrel allocating hotpluggable memory
> opportunistic.

What I was saying was that the kernel should try !hotpluggable memory
first then fall back to hotpluggable memory instead of failing boot as
nothing really is worse than failing to boot.

> >Short of being able to remap memory under the kernel, I don't think
> >this can be very generic and as a compromise trying to keep as many
> >hotpluggable nodes as possible doesn't sound too bad.
> 
> I think making one of the node hotpluggable is better. But OK, it is
> no big deal. There won't be such machine in reality, I think. :)

Hmmm... but allocating close to kernel image will keep the number of
nodes which are made un-removeable via permanent allocation to
minimum.  In most configurations that I can recall, I don't think we'd
lose anything really and the code will be much simpler and generic.
It seems like a good trade-off to me given that we need to report
which nodes are hot unpluggable no matter what.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
