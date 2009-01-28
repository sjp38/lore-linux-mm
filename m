Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C07E86B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 11:55:39 -0500 (EST)
Date: Wed, 28 Jan 2009 17:55:12 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] migration: migrate_vmas should check "vma"
Message-ID: <20090128165512.GA22588@cmpxchg.org>
References: <20090128162619.2205befd.nishimura@mxp.nes.nec.co.jp> <alpine.DEB.1.10.0901281140540.7765@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0901281140540.7765@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 28, 2009 at 11:42:36AM -0500, Christoph Lameter wrote:
> On Wed, 28 Jan 2009, Daisuke Nishimura wrote:
> 
> > migrate_vmas() should check "vma" not "vma->vm_next" for for-loop condition.
> 
> The loop condition is checked before vma = vma->vm_next. So the last
> iteration of the loop will now be run with vma = NULL?

No, the condition is always checked before the body is executed.  The
assignment to vma->vm_next happens at the end of every body.

Try this:

		int a = 2;

		for (puts("init"); puts("cond"), a; puts("next"))
			a--;

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
