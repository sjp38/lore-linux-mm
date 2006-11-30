Date: Thu, 30 Nov 2006 12:29:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
In-Reply-To: <1164917715.6588.177.camel@twins>
Message-ID: <Pine.LNX.4.64.0611301227540.24618@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl> >  <20061130101921.113055000@chello.nl>
 >  <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
 <1164913365.6588.156.camel@twins>  <Pine.LNX.4.64.0611301137120.24161@schroedinger.engr.sgi.com>
  <1164915612.6588.171.camel@twins>  <Pine.LNX.4.64.0611301210190.24331@schroedinger.engr.sgi.com>
 <1164917715.6588.177.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006, Peter Zijlstra wrote:

> > > Sure, but there is nothing wrong with using a slab page with a lower
> > > allocation rank when there is memory aplenty. 
> > What does "a slab page with a lower allocation rank" mean? Slab pages have 
> > no allocation ranks that I am aware of.
> I just added allocation rank and didn't you suggest tracking it for all
> slab pages instead of per slab?

Yes but that is not in place so I was wondering what you were talking 
about. It would help to have some longer text describing what you intend 
to do and how rank would work throughout the VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
