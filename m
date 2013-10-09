Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id BDC516B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 17:11:46 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so1522286pbb.10
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 14:11:46 -0700 (PDT)
Received: by mail-qa0-f48.google.com with SMTP id hu16so1070394qab.0
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 14:11:43 -0700 (PDT)
Date: Wed, 9 Oct 2013 17:11:36 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
Message-ID: <20131009211136.GH5592@mtj.dyndns.org>
References: <524E2032.4020106@gmail.com>
 <524E2127.4090904@gmail.com>
 <5251F9AB.6000203@zytor.com>
 <525442A4.9060709@gmail.com>
 <20131009164449.GG22495@htj.dyndns.org>
 <52558EEF.4050009@gmail.com>
 <20131009192040.GA5592@mtj.dyndns.org>
 <1381352311.5429.115.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381352311.5429.115.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello, Toshi.

On Wed, Oct 09, 2013 at 02:58:31PM -0600, Toshi Kani wrote:
> Let's not assume that memory hotplug is always a niche feature for huge
> & special systems.  It may be a niche to begin with, but it could be
> supported on VMs, which allows anyone to use.  Vasilis has been working
> on KVM to support memory hotplug.

I'm not saying hotplug will always be niche.  I'm saying the approach
we're currently taking is.  It seems fairly inflexible to hang the
whole thing on NUMA nodes.  What does the planned kvm support do?
Splitting SRAT nodes so that it can do both actual NUMA node
distribution and hotplug granuliarity?  IIRC I asked a couple times
what the long term plan was for this feature and there doesn't seem to
be any road map for this thing to become a full solution.  Unless I
misunderstood, this is more of "let's put out the fire as there
already are (or gonna be) machines which can do it" kinda thing, which
is fine too.  My point is that it doesn't make a lot of sense to
change boot sequence invasively to accomodate that.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
