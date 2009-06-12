Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D39316B005C
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 06:07:35 -0400 (EDT)
Date: Fri, 12 Jun 2009 12:07:44 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 2/5] HWPOISON: fix tasklist_lock/anon_vma locking order
Message-ID: <20090612100744.GB13607@wotan.suse.de>
References: <20090611142239.192891591@intel.com> <20090611144430.540500784@intel.com> <20090612100308.GD25568@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090612100308.GD25568@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 12:03:08PM +0200, Andi Kleen wrote:
> On Thu, Jun 11, 2009 at 10:22:41PM +0800, Wu Fengguang wrote:
> > To avoid possible deadlock. Proposed by Nick Piggin:
> 
> I disagree with the description. There's no possible deadlock right now.
> It would be purely out of paranoia.
> 
> > 
> >   You have tasklist_lock(R) nesting outside i_mmap_lock, and inside anon_vma
> >   lock. And anon_vma lock nests inside i_mmap_lock.
> > 
> >   This seems fragile. If rwlocks ever become FIFO or tasklist_lock changes
> 
> I was a bit dubious on this reasoning. If rwlocks become FIFO a lot of
> stuff will likely break.
> 
> >   type (maybe -rt kernels do it), then you could have a task holding
> 
> I think they tried but backed off quickly again
> 
> It's ok with a less scare-mongering description.

There's simply no good reason to invert ordering of locks like
this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
