Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 354788D0080
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 00:22:51 -0500 (EST)
Date: Wed, 17 Nov 2010 14:22:13 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [0/8,v3] NUMA Hotplug Emulator - Introduction & Feedbacks
Message-ID: <20101117052213.GA10671@linux-sh.org>
References: <20101117020759.016741414@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117020759.016741414@intel.com>
Sender: owner-linux-mm@kvack.org
To: shaohui.zheng@intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, ak@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 10:07:59AM +0800, shaohui.zheng@intel.com wrote:
> * PATCHSET INTRODUCTION
> 
> patch 1: Add function to hide memory region via e820 table. Then emulator will
> 	     use these memory regions to fake offlined numa nodes.
> patch 2: Infrastructure of NUMA hotplug emulation, introduce "hide node".
> patch 3: Provide an userland interface to hotplug-add fake offlined nodes.
> patch 4: Abstract cpu register functions, make these interface friend for cpu
> 		 hotplug emulation
> patch 5: Support cpu probe/release in x86, it provide a software method to hot
> 		 add/remove cpu with sysfs interface.
> patch 6: Fake CPU socket with logical CPU on x86, to prevent the scheduling
> 		 domain to build the incorrect hierarchy.
> patch 7: extend memory probe interface to support NUMA, we can add the memory to
> 		 a specified node with the interface.
> patch 8: Documentations
> 
> * FEEDBACKS & RESPONSES
> 
I had some comments on the other patches in the series that possibly got
missed because of the mail-followup-to confusion:

http://lkml.org/lkml/2010/11/15/11
http://lkml.org/lkml/2010/11/15/14
http://lkml.org/lkml/2010/11/15/15

The other one you've already dealt with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
