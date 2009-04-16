Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 69B045F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 05:29:53 -0400 (EDT)
Date: Thu, 16 Apr 2009 11:30:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 5/5] mm: prompt slqb default for oldconfig
Message-ID: <20090416093018.GA32569@wotan.suse.de>
References: <20090414164439.GA14873@wotan.suse.de> <20090414165058.GE14873@wotan.suse.de> <1239872109.15377.7.camel@penberg-laptop> <20090416092238.GL9813@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090416092238.GL9813@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 16, 2009 at 11:22:38AM +0200, Ingo Molnar wrote:
> 
> * Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> 
> > Hi Nick,
> > 
> > On Tue, 2009-04-14 at 18:50 +0200, Nick Piggin wrote:
> > > Hi Pekka,
> > > 
> > > Well there have been reasonably significant changes both for SLQB and
> > > SLUB that I thought it is better to wait one more round before merging
> > > SLQB. Also, SLQB may not have been getting as much testing as it could
> > > have in -next, due to oldconfig choosing existing config as the default.
> > > 
> > > Thanks,
> > > Nick
> > > --
> > > 
> > > Change Kconfig names for slab allocator choices to prod SLQB into being
> > > the default. Hopefully increasing testing base.
> > > 
> > > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > 
> > I went ahead and applied this too. IIRC, Ingo had some ideas how 
> > this should be handled so lets CC him as well.
> 
> I forgot it all already :)

I think I roughly followed consensus. Basically just rename the choices
so oldconfig will default to Kconfig specified rather than the existing
.config choice. We can just revert this little shim eventually.
 

> Btw., i'm wondering, why didnt this make it into .30?

Well, there was a flurry of activity on SLUB, and also one relatively
significant change to SLQB, so in the interest of getting a more uptodate
comparison, I think it better to wait one more round.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
