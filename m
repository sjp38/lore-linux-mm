Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA06321
	for <linux-mm@kvack.org>; Wed, 26 Feb 2003 14:43:35 -0800 (PST)
Date: Wed, 26 Feb 2003 14:40:15 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] allow CONFIG_SWAP=n for i386
Message-Id: <20030226144015.54ebcbcc.akpm@digeo.com>
In-Reply-To: <20030227005100.B15460@sgi.com>
References: <20030227002104.D15352@sgi.com>
	<20030226142024.614e2e0d.akpm@digeo.com>
	<20030227005100.B15460@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@sgi.com> wrote:
>
> On Wed, Feb 26, 2003 at 02:20:24PM -0800, Andrew Morton wrote:
> > > There's a bunch of minor fixes needed to disable the swap
> > > code for systems with mmu.
> > 
> > A worthy objective.
> > 
> > > +	.i_shared_sem	= __MUTEX_INITIALIZER(&swapper_space.i_shared_sem),
> > 
> > arch/um des not have __MUTEX_INITIALIZER, and I'm not sure that we want to
> > promote this to part of the kernel API, do we?
> > 
> > Might be better to leave that bit alone.  Maybe stick an initcall into
> > swap_state.c for it.
> 
> Personally I'd prefer to use __MUTEX_INITIALIZER because we really need
> a way to intialize a semaphore at compile time.  Would either using
> __SEMAPHORE_INITIALIZER() or renaming one of them to something more sane
> be okay with you?

Actually I think I misread the UML code - seems that it just includes
the host architecture's semaphore.h, so what you have should be fine.
I'll queue it up.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
