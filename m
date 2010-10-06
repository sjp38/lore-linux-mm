Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E20F66B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 12:49:41 -0400 (EDT)
Date: Wed, 6 Oct 2010 11:49:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
In-Reply-To: <20101006164326.GB17987@basil.fritz.box>
Message-ID: <alpine.DEB.2.00.1010061148080.31538@router.home>
References: <20101005185725.088808842@linux.com> <87fwwjha2u.fsf@basil.nowhere.org> <alpine.DEB.2.00.1010061057160.31538@router.home> <20101006162547.GA17987@basil.fritz.box> <alpine.DEB.2.00.1010061133210.31538@router.home>
 <20101006164326.GB17987@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Oct 2010, Andi Kleen wrote:

> > > So it would depend on that total number of caches in the system?
> >
> > Yes. Also the expiration is triggerable from user space. You can set up a
> > cron job that triggers cache expiration every minute or so.
> > movement also.
>
> That doesn't seem like a good way to do this to me. Such things should work
> without special cron jobs.

Its trivial to add a 2 second timer (or another variant) if we want the
exact slab cleanup behavior. However, then you have the disturbances again
of running code by checking all the caches in the system on all cpus.
Running the cleaning from reclaim avoids that.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
