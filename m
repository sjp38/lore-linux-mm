Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8A26B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 14:45:20 -0400 (EDT)
Date: Thu, 13 May 2010 11:05:51 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC, 3/7] NUMA hotplug emulator
Message-ID: <20100513180550.GA26440@suse.de>
References: <20100513114835.GD2169@shaohui>
 <20100513165511.GB25212@suse.de>
 <1273773292.13285.7755.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1273773292.13285.7755.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Alex Chiang <achiang@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.com, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 10:54:52AM -0700, Dave Hansen wrote:
> On Thu, 2010-05-13 at 09:55 -0700, Greg KH wrote:
> > > Add a sysfs entry "probe" under /sys/devices/system/node/:
> > > 
> > >  - to show all fake offlined nodes:
> > >     $ cat /sys/devices/system/node/probe
> > > 
> > >  - to hotadd a fake offlined node, e.g. nodeid is N:
> > >     $ echo N > /sys/devices/system/node/probe
> > 
> > As you are trying to add a new sysfs file, please create the matching
> > Documentation/ABI/ file as well.
> > 
> > Also note that sysfs files are "one value per file", which I don't think
> > this file follows, right?
> 
> I think in this case, it was meant to be a list of acceptable parameters
> rather than a set of values, kinda like /sys/power/state.  Instead, I
> guess we could have:
> 
> 	/sys/devices/system/node/probeable/3
> 	/sys/devices/system/node/probeable/43
> 	/sys/devices/system/node/probeable/65
> 	/sys/devices/system/node/probeable/5145
> 
> and the knowledge that you need to pick one of those to echo
> into /sys/devices/system/node/probe.  But, it's a lot more self
> explanatory if you 'cat /sys/devices/system/node/probe', and then pick
> one of those to echo back into the file.
> 
> Seems like a decent place to violate the "rule". :)

How big would this "list" be?  What will it look like exactly?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
