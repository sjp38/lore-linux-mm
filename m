Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A42F86B01EE
	for <linux-mm@kvack.org>; Thu, 13 May 2010 22:12:33 -0400 (EDT)
Date: Fri, 14 May 2010 10:08:11 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [RFC, 6/7] NUMA hotplug emulator
Message-ID: <20100514020811.GD4381@shaohui>
References: <20100513120016.GG2169@shaohui>
 <20100513165603.GC25212@suse.de>
 <20100514014902.GB4381@shaohui>
 <20100514020526.GB7678@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100514020526.GB7678@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg KH <gregkh@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Fri, May 14, 2010 at 10:05:26AM +0800, Wu Fengguang wrote:
> On Fri, May 14, 2010 at 09:49:02AM +0800, Zheng, Shaohui wrote:
> > On Thu, May 13, 2010 at 09:56:03AM -0700, Greg KH wrote:
> > > On Thu, May 13, 2010 at 08:00:16PM +0800, Shaohui Zheng wrote:
> > > > hotplug emulator:extend memory probe interface to support NUMA
> > > > 
> > > > Extend memory probe interface to support an extra paramter nid,
> > > > the reserved memory can be added into this node if node exists.
> > > > 
> > > > Add a memory section(128M) to node 3(boots with mem=1024m)
> > > > 
> > > > 	echo 0x40000000,3 > memory/probe
> > > > 
> > > > And more we make it friendly, it is possible to add memory to do
> > > > 
> > > > 	echo 3g > memory/probe
> > > > 	echo 1024m,3 > memory/probe
> > > > 
> > > > It maintains backwards compatibility.
> > > 
> > > Again, please document this.
> > > 
> > > thanks,
> > > 
> > > greg k-h
> > 
> > okay
> 
> Shaohui, it's useless to document a wrong interface.
> Better to fix the interface _first_, then document becomes meaningful.
Fenggunag,
	greg reminds me to add the docment into Documentation/ABI/, We miss it in
the RFC. Currently, the interface format is not finalized, when we decide the
final interface, the last step is documenting it in.
> 
> Thanks,
> Fengguang

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
