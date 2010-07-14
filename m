Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 075526201FE
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 22:04:45 -0400 (EDT)
Date: Tue, 13 Jul 2010 21:01:19 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
In-Reply-To: <20100713135650.GA6444@fancy-poultry.org>
Message-ID: <alpine.DEB.2.00.1007132055470.14067@router.home>
References: <20100709190706.938177313@quilx.com> <20100710195621.GA13720@fancy-poultry.org> <alpine.DEB.2.00.1007121010420.14328@router.home> <20100712163900.GA8513@fancy-poultry.org> <alpine.DEB.2.00.1007121156160.18621@router.home>
 <20100713135650.GA6444@fancy-poultry.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1007132055472.14067@router.home>
Content-Disposition: INLINE
Sender: owner-linux-mm@kvack.org
To: Heinz Diehl <htd@fancy-poultry.org>
Cc: Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010, Heinz Diehl wrote:

> On 13.07.2010, Christoph Lameter wrote:
>
> > Can you get us the config file. What is the value of
> > PERCPU_DYMAMIC_EARLY_SIZE?
>
> My .config file is attached. I don't know how to find out what value
> PERCPU_DYNAMIC_EARLY_SIZE is actually on, how could I do that? There's
> no such thing in my .config.

I dont see anything in there at first glance that would cause slub to
increase its percpu usage. This is straight upstream?

Try to just comment out the BUILD_BUG_ON. I had it misfire before and
fixed the formulae to no longer give false positives. Maybe that is
another case. Tejun wanted that but never was able to give me an exact
formular to check for.

At the Ottawa Linux Symposium right now so responses may be delayed.
Hotels Internet connection keeps getting clogged for some reason.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
