Date: Thu, 22 Sep 2005 13:54:51 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] __kmalloc: Generate BUG if size requested is too large.
In-Reply-To: <1127421060.10664.76.camel@localhost>
Message-ID: <Pine.LNX.4.62.0509221353200.18527@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0509221232140.17975@schroedinger.engr.sgi.com>
 <1127421060.10664.76.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Sep 2005, Dave Hansen wrote:

> On Thu, 2005-09-22 at 12:32 -0700, Christoph Lameter wrote:
> > I had an issue on ia64 where I got a bug in kernel/workqueue because kzalloc
> > returned a NULL pointer due to the task structure getting too big for the slab
> > allocator. Usually these cases are caught by the kmalloc macro in include/linux/slab.h.
> > Compilation will fail if a too big value is passed to kmalloc.
> 
> I'd be more concerned that the workqueue code wasn't checking for NULL.
> Also, the one place where I see the workqueue code using kzalloc(), it
> checks for kzalloc() failure (in __create_workqueue).

The workqueue code is checking for NULL after getting out of a another 
function. 

> > However, kzalloc uses __kmalloc which has no check for that. This
> > patch makes __kmalloc bug if a too large entity is requested.
> 
> I don't see that in current -git, either.  Which version of the kernel
> are you working against?

Look at __kmalloc in current not kzalloc. kzalloc calls __kmalloc 
since size is not a constant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
