Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 67A2F6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 12:43:31 -0400 (EDT)
Date: Wed, 6 Oct 2010 18:43:26 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
Message-ID: <20101006164326.GB17987@basil.fritz.box>
References: <20101005185725.088808842@linux.com>
 <87fwwjha2u.fsf@basil.nowhere.org>
 <alpine.DEB.2.00.1010061057160.31538@router.home>
 <20101006162547.GA17987@basil.fritz.box>
 <alpine.DEB.2.00.1010061133210.31538@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010061133210.31538@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 06, 2010 at 11:37:12AM -0500, Christoph Lameter wrote:
> On Wed, 6 Oct 2010, Andi Kleen wrote:
> 
> > > True. The shared caches can compensate for that. Without this I got
> > > regression because of too many atomic operations during draining and
> > > refilling.
> >
> > Could you just do it by smaller units? (e.g. cores on SMT systems)
> 
> The shared caches are not per node but per sharing domain (l3).

That's the same at least on Intel servers.

> > So it would depend on that total number of caches in the system?
> 
> Yes. Also the expiration is triggerable from user space. You can set up a
> cron job that triggers cache expiration every minute or so.
> movement also.

That doesn't seem like a good way to do this to me. Such things should work
without special cron jobs.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
