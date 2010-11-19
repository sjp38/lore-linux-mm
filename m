Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4CFFB6B004A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 02:15:23 -0500 (EST)
Date: Fri, 19 Nov 2010 13:54:14 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [0/8,v3] NUMA Hotplug Emulator - Introduction & Feedbacks
Message-ID: <20101119055414.GC3327@shaohui>
References: <20101117020759.016741414@intel.com>
 <20101117052213.GA10671@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117052213.GA10671@linux-sh.org>
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, ak@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 02:22:13PM +0900, Paul Mundt wrote:
> On Wed, Nov 17, 2010 at 10:07:59AM +0800, shaohui.zheng@intel.com wrote:
> > * PATCHSET INTRODUCTION
> > 
> > patch 1: Add function to hide memory region via e820 table. Then emulator will
> > 	     use these memory regions to fake offlined numa nodes.
> > patch 2: Infrastructure of NUMA hotplug emulation, introduce "hide node".
> > patch 3: Provide an userland interface to hotplug-add fake offlined nodes.
> > patch 4: Abstract cpu register functions, make these interface friend for cpu
> > 		 hotplug emulation
> > patch 5: Support cpu probe/release in x86, it provide a software method to hot
> > 		 add/remove cpu with sysfs interface.
> > patch 6: Fake CPU socket with logical CPU on x86, to prevent the scheduling
> > 		 domain to build the incorrect hierarchy.
> > patch 7: extend memory probe interface to support NUMA, we can add the memory to
> > 		 a specified node with the interface.
> > patch 8: Documentations
> > 
> > * FEEDBACKS & RESPONSES
> > 
> I had some comments on the other patches in the series that possibly got
> missed because of the mail-followup-to confusion:
> 
> http://lkml.org/lkml/2010/11/15/11
About memblock API, it is a good APIs list to manage memory region. If all the
e820 wrapper function use memblock API, the code should be very clean. currently,
no body use memblock in e820 wrapper, so we should still keep this status, unless
we decide rewrite these e820 wrapper.

Anyway, we already select other way to hide memory, we will not add wrapper on
e820 table anymore.

> http://lkml.org/lkml/2010/11/15/14

I understand, the MACROs are not functions, it will not comsume memory after
compile it. the IFDEF should be removed

> http://lkml.org/lkml/2010/11/15/15
I think that you want to say ARCH_ENABLE_NUMA_HOTPLUG_EMU here, not
ARCH_ENABLE_NUMA_EMU.  the option NUMA_HOTPLUG_EMU is a dummy item, it does not
control any codes, it just try to maintain the node/memory/cpu hotplug
emulation option together, it provides convenience when use want to enable them.


> 
> The other one you've already dealt with.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
