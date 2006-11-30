Date: Thu, 30 Nov 2006 11:33:32 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
In-Reply-To: <1164912915.6588.153.camel@twins>
Message-ID: <Pine.LNX.4.64.0611301132530.24161@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl> >  <20061130101921.113055000@chello.nl>
 >   <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
 <1164912915.6588.153.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006, Peter Zijlstra wrote:

> No, the forced allocation is to test the allocation hardness at that
> point in time. I could not think of another way to test that than to
> actually to an allocation.

Typically we do this by checking the number of free pages in a zone 
compared to the high low limits. See mmzone.h.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
