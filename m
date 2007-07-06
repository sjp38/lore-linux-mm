Date: Fri, 6 Jul 2007 09:20:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
Message-Id: <20070706092022.b9b5fbcc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070706071853.9434deae.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
	<20070705181308.GB8320@stroyan.net>
	<20070706071853.9434deae.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mike Stroyan <mike@stroyan.net>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, clameter@sgi.com, y-goto@jp.fujitsu.com, dmosberger@gmail.com, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jul 2007 07:18:53 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 5 Jul 2007 12:13:09 -0600
> Mike Stroyan <mike@stroyan.net> wrote:
> >   The L3 cache is involved in the HP-UX defect description because the
> > earlier HP-UX patch PHKL_33781 added flushing of the instruction cache
> > when an executable mapping was removed.  Linux never added that
> > unsuccessfull attempt at montecito cache coherency.  In the current
> > linux situation it can execute old cache lines straight from L2 icache.
> > 
> Hmm... I couldn't understand "why icache includes old lines in a new page."
> This happens at
>  - a file is newly loaded into page-cache.
>  - only on NFS.
>  - happens very *often* if the program is unlucky.
> 
> So I wrote my understainding as I think.
> 
I'll remove reference to HP-UX in the next post. And rewrite all description.

> > 
> >   The only defect that I see in the current implementation of
> > lazy_mmu_prot_update() is that it is called too late in some
> > functions that are already calling it.  Are your large changes
> > attempting to correct other defects?  Or are you simplifying
> > away potentially valuable code because you don't understand it?
> > 
> I know your *simple* patch in April wasn't included. So I wrote this.
> In April thread, commenter's advices was "implement flush_icache_page()" I think.  
> If you have a better patch, please post.
> 
I'll check callers of lazy_mmu_prot_update() again and remove uncecessary calls.
But, basically, i-cache flush will be necessary when VM_EXEC is on. PG_arch_1 will
help us for optimization.

-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
