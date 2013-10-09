Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5D32C6B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 17:19:27 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so1556157pdj.31
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 14:19:27 -0700 (PDT)
Message-ID: <5255C730.90602@zytor.com>
Date: Wed, 09 Oct 2013 14:14:24 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
References: <524E2032.4020106@gmail.com> <524E2127.4090904@gmail.com> <5251F9AB.6000203@zytor.com> <525442A4.9060709@gmail.com> <20131009164449.GG22495@htj.dyndns.org> <52558EEF.4050009@gmail.com> <20131009192040.GA5592@mtj.dyndns.org> <1381352311.5429.115.camel@misato.fc.hp.com> <20131009211136.GH5592@mtj.dyndns.org>
In-Reply-To: <20131009211136.GH5592@mtj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Toshi Kani <toshi.kani@hp.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On 10/09/2013 02:11 PM, Tejun Heo wrote:
> Hello, Toshi.
> 
> On Wed, Oct 09, 2013 at 02:58:31PM -0600, Toshi Kani wrote:
>> Let's not assume that memory hotplug is always a niche feature for huge
>> & special systems.  It may be a niche to begin with, but it could be
>> supported on VMs, which allows anyone to use.  Vasilis has been working
>> on KVM to support memory hotplug.
> 
> I'm not saying hotplug will always be niche.  I'm saying the approach
> we're currently taking is.  It seems fairly inflexible to hang the
> whole thing on NUMA nodes.  What does the planned kvm support do?
> Splitting SRAT nodes so that it can do both actual NUMA node
> distribution and hotplug granuliarity?  IIRC I asked a couple times
> what the long term plan was for this feature and there doesn't seem to
> be any road map for this thing to become a full solution.  Unless I
> misunderstood, this is more of "let's put out the fire as there
> already are (or gonna be) machines which can do it" kinda thing, which
> is fine too.  My point is that it doesn't make a lot of sense to
> change boot sequence invasively to accomodate that.
> 

I would also argue that in the VM scenario -- and arguable even in the
hardware scenario -- the right thing is to not expose the flexible
memory in the e820/EFI tables, and instead have it hotadded (possibly
*immediately* so) on boot.  This avoids both the boot time funnies as
well as the scaling issues with metadata.

The whole reason for VMs wanting this is because ballooning doesn't
scale with regards to metadata.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
