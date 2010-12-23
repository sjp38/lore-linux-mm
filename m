Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 652096B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 21:24:10 -0500 (EST)
Date: Wed, 22 Dec 2010 18:20:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [3/7, v9] NUMA Hotplug Emulator: Add node hotplug emulation
Message-Id: <20101222182022.a5d5da8d.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1012221736110.13932@chino.kir.corp.google.com>
References: <20101210073119.156388875@intel.com>
	<20101210073242.462037866@intel.com>
	<20101222162723.72075372.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1012221736110.13932@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Haicheng Li <haicheng.li@linux.intel.com>, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, Shaohui Zheng <shaohui.zheng@linux.intel.com>, dave@linux.vnet.ibm.com, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 2010 17:38:44 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Wed, 22 Dec 2010, Andrew Morton wrote:
> 
> > > Index: linux-hpe4/mm/memory_hotplug.c
> > > ===================================================================
> > > --- linux-hpe4.orig/mm/memory_hotplug.c	2010-11-30 12:40:43.757622001 +0800
> > > +++ linux-hpe4/mm/memory_hotplug.c	2010-11-30 14:02:33.877622002 +0800
> > > @@ -924,3 +924,63 @@
> > >  }
> > >  #endif /* CONFIG_MEMORY_HOTREMOVE */
> > >  EXPORT_SYMBOL_GPL(remove_memory);
> > > +
> > > +#ifdef CONFIG_DEBUG_FS
> > > +#include <linux/debugfs.h>
> > > +
> > > +static struct dentry *memhp_debug_root;
> > > +
> > > +static ssize_t add_node_store(struct file *file, const char __user *buf,
> > > +				size_t count, loff_t *ppos)
> > > +{
> > > +	nodemask_t mask;
> > 
> > NODEMASK_ALLOC()?
> > 
> 
> We traditionally haven't been using NODEMASK_ALLOC() in sysfs (or, in this 
> case, debugfs) functions because they're never deep in a call chain.  Even 
> for 4K node support, which isn't a supported config on any arch that 
> allows CONFIG_MEMORY_HOTPLUG, this would only be 512 bytes on the short 
> stack.

I bet linux-2.6.227 supports a meganode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
