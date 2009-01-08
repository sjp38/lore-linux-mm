Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ECC1C6B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 11:55:15 -0500 (EST)
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <alpine.LFD.2.00.0901080842180.3283@localhost.localdomain>
References: <alpine.LFD.2.00.0901070833430.3057@localhost.localdomain>
	 <20090107.125133.214628094.davem@davemloft.net>
	 <20090108030245.e7c8ceaf.akpm@linux-foundation.org>
	 <20090108.082413.156881254.davem@davemloft.net>
	 <alpine.LFD.2.00.0901080842180.3283@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 08 Jan 2009 11:55:01 -0500
Message-Id: <1231433701.14304.24.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, peterz@infradead.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, 2009-01-08 at 08:48 -0800, Linus Torvalds wrote:
> 
> On Thu, 8 Jan 2009, David Miller wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Thu, 8 Jan 2009 03:02:45 -0800
> > 
> > > The kernel can't get this right - it doesn't know the usage
> > > patterns/workloads, etc.
> > 
> > I don't agree with that.
> 
> We can certainly try to tune it better. 
> 

Does it make sense to hook into kupdate?  If kupdate finds it can't meet
the no-data-older-than 30 seconds target, it lowers the sync/async combo
down to some reasonable bottom.  

If it finds it is going to sleep without missing the target, raise the
combo up to some reasonable top.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
