Date: Thu, 30 Nov 2006 11:37:30 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
In-Reply-To: <1164913365.6588.156.camel@twins>
Message-ID: <Pine.LNX.4.64.0611301137120.24161@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl> >  <20061130101921.113055000@chello.nl>
 >   <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
 <1164913365.6588.156.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006, Peter Zijlstra wrote:

> On Thu, 2006-11-30 at 10:52 -0800, Christoph Lameter wrote:
> 
> > I would think that one would need a rank with each cached object and 
> > free slab in order to do this the right way.
> 
> Allocation hardness is a temporal attribute, ie. it changes over time.
> Hence I do it per slab.

cached objects are also temporal and change over time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
