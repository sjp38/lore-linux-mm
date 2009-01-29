Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CB54B6B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 20:22:01 -0500 (EST)
Date: Thu, 29 Jan 2009 10:16:23 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] migration: migrate_vmas should check "vma"
Message-Id: <20090129101623.0d64d81b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090128165512.GA22588@cmpxchg.org>
References: <20090128162619.2205befd.nishimura@mxp.nes.nec.co.jp>
	<alpine.DEB.1.10.0901281140540.7765@qirst.com>
	<20090128165512.GA22588@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jan 2009 17:55:12 +0100, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Wed, Jan 28, 2009 at 11:42:36AM -0500, Christoph Lameter wrote:
> > On Wed, 28 Jan 2009, Daisuke Nishimura wrote:
> > 
> > > migrate_vmas() should check "vma" not "vma->vm_next" for for-loop condition.
> > 
> > The loop condition is checked before vma = vma->vm_next. So the last
> > iteration of the loop will now be run with vma = NULL?
> 
> No, the condition is always checked before the body is executed.  The
> assignment to vma->vm_next happens at the end of every body.
> 
So, I think in current code the loop body is not executed
about the last vma in the list.


Thanks,
Daisuke Nishimura.

> Try this:
> 
> 		int a = 2;
> 
> 		for (puts("init"); puts("cond"), a; puts("next"))
> 			a--;
> 
> 	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
