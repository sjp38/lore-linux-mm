Date: Fri, 21 Mar 2008 12:00:08 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [2/2] vmallocinfo: Add caller information
Message-ID: <20080321110008.GW20420@elte.hu>
References: <20080318222701.788442216@sgi.com> <20080318222827.519656153@sgi.com> <20080319214227.GA4454@elte.hu> <Pine.LNX.4.64.0803191659410.4645@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803191659410.4645@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 19 Mar 2008, Ingo Molnar wrote:
> 
> > 
> > * Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > Add caller information so that /proc/vmallocinfo shows where the 
> > > allocation request for a slice of vmalloc memory originated.
> > 
> > please use one simple save_stack_trace() instead of polluting a dozen 
> > architectures with:
> 
> save_stack_trace() depends on CONFIG_STACKTRACE which is only 
> available when debugging is compiled it. I was more thinking about 
> this as a generally available feature.

then make STACKTRACE available generally via the patch below.

	Ingo

------------------------------------------->
Subject: debugging: always enable stacktrace
From: Ingo Molnar <mingo@elte.hu>
Date: Fri Mar 21 11:48:32 CET 2008

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 lib/Kconfig.debug |    1 -
 1 file changed, 1 deletion(-)

Index: linux-x86.q/lib/Kconfig.debug
===================================================================
--- linux-x86.q.orig/lib/Kconfig.debug
+++ linux-x86.q/lib/Kconfig.debug
@@ -387,7 +387,6 @@ config DEBUG_LOCKING_API_SELFTESTS
 
 config STACKTRACE
 	bool
-	depends on DEBUG_KERNEL
 	depends on STACKTRACE_SUPPORT
 
 config DEBUG_KOBJECT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
