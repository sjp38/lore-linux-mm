Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6304C6B005C
	for <linux-mm@kvack.org>; Thu, 29 Jan 2009 19:43:59 -0500 (EST)
Date: Fri, 30 Jan 2009 09:30:18 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] migration: migrate_vmas should check "vma"
Message-Id: <20090130093018.c209d70d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090129001849.9f8fdcb3.akpm@linux-foundation.org>
References: <20090128162619.2205befd.nishimura@mxp.nes.nec.co.jp>
	<alpine.DEB.1.10.0901281140540.7765@qirst.com>
	<20090128165512.GA22588@cmpxchg.org>
	<20090129101623.0d64d81b.nishimura@mxp.nes.nec.co.jp>
	<20090129001849.9f8fdcb3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jan 2009 00:18:49 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 29 Jan 2009 10:16:23 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Wed, 28 Jan 2009 17:55:12 +0100, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > On Wed, Jan 28, 2009 at 11:42:36AM -0500, Christoph Lameter wrote:
> > > > On Wed, 28 Jan 2009, Daisuke Nishimura wrote:
> > > > 
> > > > > migrate_vmas() should check "vma" not "vma->vm_next" for for-loop condition.
> > > > 
> > > > The loop condition is checked before vma = vma->vm_next. So the last
> > > > iteration of the loop will now be run with vma = NULL?
> > > 
> > > No, the condition is always checked before the body is executed.  The
> > > assignment to vma->vm_next happens at the end of every body.
> > > 
> > So, I think in current code the loop body is not executed
> > about the last vma in the list.
> > 
> 
> Yep.
> 
> Is this serious enough to bother fixing in 2.6.29?
IIUC, there is no user of vm_ops->migrate() now, so this bug causes
no practical problems.

I think it's trival and simple enough to go in .29, but I don't have
any objection if you postpone this patch.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
