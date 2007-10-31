Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l9VEH3Hc000688
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 10:17:03 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9VFGDT0112324
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 09:17:21 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9VExBTA028910
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 08:59:11 -0600
Subject: Re: [RFC] hotplug memory remove - walk_memory_resource for ppc64
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20071031143423.586498c3.kamezawa.hiroyu@jp.fujitsu.com>
References: <1191346196.6106.20.camel@dyn9047017100.beaverton.ibm.com>
	 <18178.52359.953289.638736@cargo.ozlabs.ibm.com>
	 <1193771951.8904.22.camel@dyn9047017100.beaverton.ibm.com>
	 <20071031142846.aef9c545.kamezawa.hiroyu@jp.fujitsu.com>
	 <20071031143423.586498c3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 31 Oct 2007 08:02:40 -0800
Message-Id: <1193846560.17412.3.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org, linux-mm <linux-mm@kvack.org>, anton@au1.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-31 at 14:34 +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 31 Oct 2007 14:28:46 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > ioresource was good structure for remembering "which memory is conventional
> > memory" and i386/x86_64/ia64 registered conventional memory as "System RAM",
> > when I posted patch. (just say "System Ram" is not for memory hotplug.)
> > 
> If I remember correctly, System RAM is for kdump (to know which memory should
> be dumped.) Then, memory-hotadd/remove has to modify it anyway.

Yes. kdump uses it for finding memory holes on x86/x86-64 (not sure
about ia64). On PPC64, since its not represented in /proc/iomem, we
end up reading /proc/device-tree/memory* nodes to construct the 
memory map.

Paul's concern is, since we didn't need it so far - why we need this
for hotplug memory remove to work ? It might break API for *unknown*
applications. Its unfortunate that, hotplug memory add updates 
/proc/iomem. We can deal with it later, as a separate patch.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
