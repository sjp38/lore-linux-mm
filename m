Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 93C976B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 15:48:03 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so1405301pbb.27
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 12:48:03 -0700 (PDT)
Received: by mail-ye0-f174.google.com with SMTP id r14so335539yen.5
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 12:47:56 -0700 (PDT)
Date: Wed, 9 Oct 2013 15:47:47 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
Message-ID: <20131009194747.GC5592@mtj.dyndns.org>
References: <524E2032.4020106@gmail.com>
 <524E2127.4090904@gmail.com>
 <5251F9AB.6000203@zytor.com>
 <525442A4.9060709@gmail.com>
 <20131009164449.GG22495@htj.dyndns.org>
 <52558EEF.4050009@gmail.com>
 <20131009192040.GA5592@mtj.dyndns.org>
 <5255AEC1.7040500@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5255AEC1.7040500@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello,

On Wed, Oct 09, 2013 at 12:30:09PM -0700, Dave Hansen wrote:
> On 10/09/2013 12:20 PM, Tejun Heo wrote:
> > Realistically tho, why would people be using 4k mappings on 2T
> > machines?
> 
> CONFIG_DEBUG_PAGEALLOC and CONFIG_KMEMCHECK both disable using >4k
> pages.  I actually ran in to this on a 1TB machine a few weeks ago:
> 
> 	https://lkml.org/lkml/2013/8/9/546
> 
> So it's not a common case for stuff that customers have, but it sure as
> *HECK* is needed for debugging.

But as I said in the same paragraph, parsing SRAT earlier doesn't
solve the problem in itself either.  Ignoring the option if 4k mapping
is required and memory consumption would be prohibitive should work,
no?  Something like that would be necessary if we're gonna worry about
cases like this no matter how we implement it, but, frankly, I'm not
sure this is something worth worrying about.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
