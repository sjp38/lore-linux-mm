Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 82AB48D0001
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 00:17:30 -0500 (EST)
Date: Sat, 27 Nov 2010 21:17:49 -0800
From: Greg KH <gregkh@suse.de>
Subject: Re: [patch 2/2 v2] mm: add node hotplug emulation
Message-ID: <20101128051749.GA11474@suse.de>
References: <alpine.DEB.2.00.1011181321470.26680@chino.kir.corp.google.com>
 <20101119003225.GB3327@shaohui>
 <alpine.DEB.2.00.1011201645230.10618@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1011201826140.12889@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1011201827540.12889@chino.kir.corp.google.com>
 <20101121173438.GA3922@suse.de>
 <alpine.DEB.2.00.1011211346160.26304@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1011211505440.30377@chino.kir.corp.google.com>
 <20101122005658.GA6710@suse.de>
 <alpine.DEB.2.00.1011271750140.3764@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011271750140.3764@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Shaohui Zheng <shaohui.zheng@intel.com>, Paul Mundt <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Nov 27, 2010 at 05:52:03PM -0800, David Rientjes wrote:
> On Sun, 21 Nov 2010, Greg KH wrote:
> 
> > > Add an interface to allow new nodes to be added when performing memory
> > > hot-add.  This provides a convenient interface to test memory hotplug
> > > notifier callbacks and surrounding hotplug code when new nodes are
> > > onlined without actually having a machine with such hotpluggable SRAT
> > > entries.
> > > 
> > > This adds a new debugfs interface at /sys/kernel/debug/hotplug/add_node
> > 
> > The rule for debugfs is "there are no rules", but perhaps you might want
> > to name "hotplug" a bit more specific for what you are doing?  "hotplug"
> > means pretty much anything these days, so how about s/hotplug/node/
> > instead as that is what you are controlling.
> > 
> > Just a suggestion...
> > 
> 
> Hmm, how strongly do you feel about that?  There's nothing node specific 
> in the memory hotplug code where this lives, so we'd probably have to 
> define the dentry elsewhere and even then it would only needed for 
> CONFIG_MEMORY_HOTPLUG.
> 
> I personally don't see this as a node debugging but rather memory hotplug 
> callback debugging.

Then name it as such, not the generic "hotplug" like you just did.
"mem_hotplug" would make sense, right?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
