Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8916B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 22:31:42 -0500 (EST)
Date: Fri, 23 Jan 2009 04:31:33 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123033133.GB20098@wotan.suse.de>
References: <20090121143008.GV24891@wotan.suse.de> <20090121145918.GA11311@elte.hu> <20090121165600.GA16695@wotan.suse.de> <20090121174010.GA2998@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090121174010.GA2998@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 21, 2009 at 06:40:10PM +0100, Ingo Molnar wrote:
> 
> * Nick Piggin <npiggin@suse.de> wrote:
> 
> > On Wed, Jan 21, 2009 at 03:59:18PM +0100, Ingo Molnar wrote:
> > > 
> > > Mind if i nitpick a bit about minor style issues? Since this is going to 
> > > be the next Linux SLAB allocator we might as well do it perfectly :-)
> > 
> > Well here is an incremental patch which should get most of the issues 
> > you pointed out, most of the sane ones that checkpatch pointed out, and 
> > a few of my own ;)
> 
> here's an incremental one ontop of your incremental patch, enhancing some 
> more issues. I now find the code very readable! :-)

Thanks! I'll go through it and apply it. I'll raise any issues if I
am particularly against them ;)

> ( in case you are wondering about the placement of bit_spinlock.h - that 
>   file needs fixing, just move it to the top of the file and see the build 
>   break. But that's a separate patch.)

Ah, SLQB doesn't use bit spinlocks anyway, so I'll just get rid of that.
I'll see if there are any other obviously unneeded headers too.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
