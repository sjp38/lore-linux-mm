Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 50DD56B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 15:52:24 -0500 (EST)
Subject: Re: [RFC MM] Accessors for mm locking
From: Andi Kleen <andi@firstfloor.org>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1>
Date: Thu, 05 Nov 2009 21:52:12 +0100
In-Reply-To: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1> (Christoph Lameter's message of "Thu, 5 Nov 2009 14:19:25 -0500 (EST)")
Message-ID: <87vdho7kzn.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Christoph Lameter <cl@linux-foundation.org> writes:

> From: Christoph Lameter <cl@linux-foundation.org>
> Subject: [RFC MM] Accessors for mm locking
>
> Scaling of MM locking has been a concern for a long time. With the arrival of
> high thread counts in average business systems we may finally have to do
> something about that.

Thanks for starting to think about that. Yes, this is definitely
something that needs to be addressed.

> Index: linux-2.6/arch/x86/mm/fault.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/mm/fault.c	2009-11-05 13:02:35.000000000 -0600
> +++ linux-2.6/arch/x86/mm/fault.c	2009-11-05 13:02:41.000000000 -0600
> @@ -758,7 +758,7 @@ __bad_area(struct pt_regs *regs, unsigne
>  	 * Something tried to access memory that isn't in our memory map..
>  	 * Fix it, but check if it's kernel or user first..
>  	 */
> -	up_read(&mm->mmap_sem);
> +	mm_reader_unlock(mm);

My assumption was that a suitable scalable lock (or rather multi locks) 
would need to know about the virtual address, or at least the VMA. 
As in doing range locking for different address space areas.

So this simple abstraction doesn't seem to be enough to really experiment?

Or what did you have in mind for improving the locking without using
ranges?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
