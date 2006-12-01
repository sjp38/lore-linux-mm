Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0611301132530.24161@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl> >
	 <20061130101921.113055000@chello.nl> >
	 <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
	 <1164912915.6588.153.camel@twins>
	 <Pine.LNX.4.64.0611301132530.24161@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 01 Dec 2006 12:28:47 +0100
Message-Id: <1164972527.6588.186.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-11-30 at 11:33 -0800, Christoph Lameter wrote:
> On Thu, 30 Nov 2006, Peter Zijlstra wrote:
> 
> > No, the forced allocation is to test the allocation hardness at that
> > point in time. I could not think of another way to test that than to
> > actually to an allocation.
> 
> Typically we do this by checking the number of free pages in a zone 
> compared to the high low limits. See mmzone.h.

This doesn't work under high load because of direct reclaim. And if I go
run direct reclaim to test if I can raise the free pages level to an
acceptable level for the given gfp flags, I might as well do the whole
allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
