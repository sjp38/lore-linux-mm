Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 67C156B005C
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 12:10:42 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] SLQB slab allocator
Date: Sat, 24 Jan 2009 04:09:26 +1100
References: <20090114150900.GC25401@wotan.suse.de> <alpine.DEB.1.10.0901231042380.32253@qirst.com> <20090123161017.GC14517@wotan.suse.de>
In-Reply-To: <20090123161017.GC14517@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200901240409.27449.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Saturday 24 January 2009 03:10:17 Nick Piggin wrote:
> On Fri, Jan 23, 2009 at 10:52:43AM -0500, Christoph Lameter wrote:
> > On Fri, 23 Jan 2009, Nick Piggin wrote:
> > > > Typically we traverse lists of objects that are in the same slab
> > > > cache.
> > >
> > > Very often that is not the case. And the price you pay for that is that
> > > you have to drain and switch freelists whenever you encounter an object
> > > that is not on the same page.
> >
> > SLUB can directly free an object to any slab page. "Queuing" on free via
> > the per cpu slab is only possible if the object came from that per cpu
> > slab. This is typically only the case for objects that were recently
> > allocated.
>
> Ah yes ok that's right. But then you don't get LIFO allocation
> behaviour for those cases.

And actually really this all just stems from conceptually in fact you
_do_ switch to a different queue (from the one being allocated from)
to free the object if it is on a different page. Because you have a
set of queues (a queue per-page). So freeing to a different queue is
where you lose LIFO property.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
