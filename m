Date: Thu, 30 Nov 2006 09:31:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
Message-Id: <20061130093105.d872c49d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061129030655.941148000@menage.corp.google.com>
References: <20061129030655.941148000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Nov 2006 19:06:55 -0800
menage@google.com wrote:

> --
> 
> We're trying to use NUMA node isolation as a form of job resource
> control at Google, and the existing page migration APIs are all bound
> to individual processes and so are a bit clunky to use when you just
> want to affect all the pages on a given node.
> 
> How about an API to allow userspace to direct page migration (and page
> reclaim) on a per-node basis? This patch provides such an API, based
> around sysfs; a system call approach would certainly be possible too.
>
> It sort of overlaps with memory hot-unplug, but is simpler since it's
> not so bad if we miss a few pages.
> 
> Comments? Also, can anyone clarify whether I need any locking when
> sacnning the pages in a pgdat? As far as I can see, even with memory
> hotplug this number can only increase, not decrease.
> 

Hi, I'm one of memory-hot-unplug men. (But I can't go ahead for now.)

a few comments.
1. memory hot unplug will be implemnted based on *section* not on *node*.
   section <-> node relationship will be displayed.

2. AFAIK, migrating pages without taking write lock of any mm->sem will
   cause problem. anon_vma can be freed while migration.

3. It's maybe better to add a hook to stop page allocation from the target node(zone).
   you may want to use this feature under heavly load.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
