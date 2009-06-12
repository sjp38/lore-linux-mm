Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 106126B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:58:40 -0400 (EDT)
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1244800695.7172.115.camel@pasglop>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu> <1244798515.7172.99.camel@pasglop>
	 <84144f020906120224v5ef44637pb849fd247eab84ea@mail.gmail.com>
	 <1244799389.7172.110.camel@pasglop>
	 <Pine.LNX.4.64.0906121244020.30911@melkki.cs.Helsinki.FI>
	 <1244800695.7172.115.camel@pasglop>
Date: Fri, 12 Jun 2009 13:00:29 +0300
Message-Id: <1244800829.30512.40.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jun 2009, Benjamin Herrenschmidt wrote:
> > > Take a break, take a step back, and look at the big picture. Do you
> > > really want to find all the needles in the haystack or just make sure
> > > you wear gloves when handling the hay ? :-)

On Fri, 2009-06-12 at 12:45 +0300, Pekka J Enberg wrote:
> > Well, I would like to find the needles but I think we should do it with 
> > gloves on.
> > 
> > If everyone is happy with this version of Ben's patch, I'm going to just 
> > apply it and push it to Linus.

On Fri, 2009-06-12 at 19:58 +1000, Benjamin Herrenschmidt wrote:
> Thanks :-) Looks right at first glance. I'll test tomorrow.

Nick? I do think this is the best short-term solution. We can get rid of
it later on if we decide to fix up the callers instead.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
