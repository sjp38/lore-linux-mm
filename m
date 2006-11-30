Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0611301137120.24161@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl> >
	 <20061130101921.113055000@chello.nl> >
	 <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
	 <1164913365.6588.156.camel@twins>
	 <Pine.LNX.4.64.0611301137120.24161@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 30 Nov 2006 20:40:12 +0100
Message-Id: <1164915612.6588.171.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-11-30 at 11:37 -0800, Christoph Lameter wrote:
> On Thu, 30 Nov 2006, Peter Zijlstra wrote:
> 
> > On Thu, 2006-11-30 at 10:52 -0800, Christoph Lameter wrote:
> > 
> > > I would think that one would need a rank with each cached object and 
> > > free slab in order to do this the right way.
> > 
> > Allocation hardness is a temporal attribute, ie. it changes over time.
> > Hence I do it per slab.
> 
> cached objects are also temporal and change over time.

Sure, but there is nothing wrong with using a slab page with a lower
allocation rank when there is memory aplenty. 

I'm just not seeing how keeping all individual page ranks would make
this better.

The only thing that matters is the actual free pages limit, not that of
a few allocation ago. The stored rank is a safe shortcut for it allows
harder allocation to use easily obtainable free space not the other way
around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
