Date: Thu, 27 Feb 2003 00:51:00 -0500
From: Christoph Hellwig <hch@sgi.com>
Subject: Re: [PATCH] allow CONFIG_SWAP=n for i386
Message-ID: <20030227005100.B15460@sgi.com>
References: <20030227002104.D15352@sgi.com> <20030226142024.614e2e0d.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030226142024.614e2e0d.akpm@digeo.com>; from akpm@digeo.com on Wed, Feb 26, 2003 at 02:20:24PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 26, 2003 at 02:20:24PM -0800, Andrew Morton wrote:
> > There's a bunch of minor fixes needed to disable the swap
> > code for systems with mmu.
> 
> A worthy objective.
> 
> > +	.i_shared_sem	= __MUTEX_INITIALIZER(&swapper_space.i_shared_sem),
> 
> arch/um des not have __MUTEX_INITIALIZER, and I'm not sure that we want to
> promote this to part of the kernel API, do we?
> 
> Might be better to leave that bit alone.  Maybe stick an initcall into
> swap_state.c for it.

Personally I'd prefer to use __MUTEX_INITIALIZER because we really need
a way to intialize a semaphore at compile time.  Would either using
__SEMAPHORE_INITIALIZER() or renaming one of them to something more sane
be okay with you?

If we need to go the initcall way there's already one in swapfile.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
