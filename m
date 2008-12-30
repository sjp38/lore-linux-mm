Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 43ED96B0044
	for <linux-mm@kvack.org>; Mon, 29 Dec 2008 22:42:54 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
Date: Tue, 30 Dec 2008 14:42:36 +1100
References: <49416494.6040009@goop.org> <200707241140.12945.nickpiggin@yahoo.com.au> <49470433.4050504@goop.org>
In-Reply-To: <49470433.4050504@goop.org>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200812301442.37654.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 16 December 2008 12:28:19 Jeremy Fitzhardinge wrote:
> Nick Piggin wrote:
> > On Friday 12 December 2008 12:59, Jeremy Fitzhardinge wrote:

> >> No.  Well, yes, it would, but Xen itself will do whatever tlb flushes
> >> are necessary to keep it safe (it must, since it doesn't trust guest
> >> kernels).  It's fairly clever about working out which cpus need flushing
> >> and if other flushes have already done the job.
> >
> > OK. Yeah, then the problem is simply that the guest may reuse that
> > virtual memory for another vmap.
>
> Hm.  What you would you think of a "deferred tlb flush" flag (or
> something) to cause the next vmap to do the tlb flushes, in the case the
> vunmap happens in a context where the flushes can't be done?

Sorry to get back to you late... I would just prefer to have a flushing mode
that clears page tables but leaves the vm entries there that will get picked
up and flushed naturally as needed.

I have patches to move the tlb flushing to an asynchronous process context...
but all tweaks to that (including flushing at vmap) are just variations on the
existing flushing scheme and don't solve your problem, so I don't think we
really need to change that for the moment (my patches are mainly for latency
improvement and to allow vunmap to be usable from interrupt context).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
