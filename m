Date: Fri, 7 Sep 2007 03:56:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] core: fix build error when referencing arch
 specific structures
Message-Id: <20070907035632.13ceb928.akpm@linux-foundation.org>
In-Reply-To: <200709070828.05730.ak@suse.de>
References: <20070907040943.467530005@sgi.com>
	<200709070828.05730.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: travis@sgi.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Fri, 7 Sep 2007 08:28:05 +0100 Andi Kleen <ak@suse.de> wrote:
> On Friday 07 September 2007 05:09, travis@sgi.com wrote:
> > Since the core kernel routines need to reference cpu_sibling_map,
> > whether it be a static array or a per_cpu data variable, an access
> > function has been defined.
> >
> > In addition, changes have been made to the ia64 and ppc64 arch's to
> > move the cpu_sibling_map from a static cpumask_t array [NR_CPUS] to
> > be per_cpu cpumask_t arrays.
> >
> > Note that I do not have the ability to build or test patch 3/3, the
> > ppc64 changes.
> >
> > Patches are referenced against 2.6.23-rc4-mm1 .
> 
> It would be better if you could redo the patches with the original patches
> reverted, not incremental changes. In the end we'll need a full patch set
> with full changelog anyways, not a series of incremental fixes.

yup
 
> Also I guess some powerpc testers would be needed. Perhaps cc the
> maintainers?
> 

yup

All architectures except sparc64 are now done - please have a shot at doing
sparc64 as well.

I'd suggest that we not implement that cpu_sibling_map() macro and just
open-code the per_cpu() everywhere.  So henceforth any architecture which
implements CONFIG_SCHED_SMT must implement the per-cpu sibling map.

That's nice and simple, and avoids the unpleasant
pretend-function-used-as-an-lvalue trick.  (Well OK, per_cpu() does
that, but let's avoid resinning).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
