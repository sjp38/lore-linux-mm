Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1B20A6B004F
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 07:39:00 -0400 (EDT)
Date: Mon, 1 Jun 2009 13:39:33 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090601113933.GD5018@wotan.suse.de>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090528165625.GA17572@sgi.com> <20090530064244.GJ1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090530064244.GJ1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Russ Anderson <rja@sgi.com>, hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Sat, May 30, 2009 at 08:42:44AM +0200, Andi Kleen wrote:
> Sorry for late answer, email slipped out earlier.
> 
> On Thu, May 28, 2009 at 11:56:25AM -0500, Russ Anderson wrote:
> > > I changed it to 
> > > 
> > >  "MCE: Unable to determine user space address during error handling\n")
> > > 
> > > Still not perfect, but hopefully better.
> > 
> > Is it even worth having a message at all?  Does the fact that page_address_in_vma()
> 
> I like having a message so that I can see when it happens.
> 
> > failed change the behavior in any way?  (Does tk->addr == 0 matter?)  From
> 
> It just doesn't report an address to the user (or rather 0)
> 
> > If the message is for developers/debugging, it would be nice to have more
> 
> It's not really for debugging only, it's a legitimate case. Typically
> when the process unmaps or remaps in parallel. Of course when it currently
> unmaps you could argue it doesn't need the data anymore and doesn't
> need to be killed (that's true), but that doesn't work for mremap()ing.
> I considered at some point to loop, but that would risk live lock.
> So it just prints and reports nothing.
> 
> The only ugly part is the ambiguity of reporting a 0 address (in theory
> there could be real memory 0 on virtual 0), but that didn't seem to be
> enough an issue to fix.

Just isn't really something we typically give a dmesg for.

Surely you can test it out these cases with debugging code or printks
and then take them out of production code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
