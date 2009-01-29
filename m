Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 48DBB6B0044
	for <linux-mm@kvack.org>; Thu, 29 Jan 2009 03:19:00 -0500 (EST)
Date: Thu, 29 Jan 2009 00:18:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] migration: migrate_vmas should check "vma"
Message-Id: <20090129001849.9f8fdcb3.akpm@linux-foundation.org>
In-Reply-To: <20090129101623.0d64d81b.nishimura@mxp.nes.nec.co.jp>
References: <20090128162619.2205befd.nishimura@mxp.nes.nec.co.jp>
	<alpine.DEB.1.10.0901281140540.7765@qirst.com>
	<20090128165512.GA22588@cmpxchg.org>
	<20090129101623.0d64d81b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jan 2009 10:16:23 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 28 Jan 2009 17:55:12 +0100, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Wed, Jan 28, 2009 at 11:42:36AM -0500, Christoph Lameter wrote:
> > > On Wed, 28 Jan 2009, Daisuke Nishimura wrote:
> > > 
> > > > migrate_vmas() should check "vma" not "vma->vm_next" for for-loop condition.
> > > 
> > > The loop condition is checked before vma = vma->vm_next. So the last
> > > iteration of the loop will now be run with vma = NULL?
> > 
> > No, the condition is always checked before the body is executed.  The
> > assignment to vma->vm_next happens at the end of every body.
> > 
> So, I think in current code the loop body is not executed
> about the last vma in the list.
> 

Yep.

Is this serious enough to bother fixing in 2.6.29?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
