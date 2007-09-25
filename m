Date: Tue, 25 Sep 2007 14:43:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/5] mm: test and set zone reclaim lock before starting
 reclaim
In-Reply-To: <Pine.LNX.4.64.0709251437380.5072@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709251441090.3660@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
 <46F88DFB.3020307@linux.vnet.ibm.com> <alpine.DEB.0.9999.0709242129420.31515@chino.kir.corp.google.com> <46F8A7FE.7000907@linux.vnet.ibm.com> <Pine.LNX.4.64.0709251414480.4831@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709251418010.32744@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709251437380.5072@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007, Christoph Lameter wrote:

> > > > > One thing that has been changed in -mm with regard to my last patchset is 
> > > > > that kswapd and try_to_free_pages() are allowed to call shrink_zone() 
> > > > > concurrently.
> > > > > 
> > > > 
> > > > Aah.. interesting. Could you define concurrently more precisely,
> > > > concurrently as in the same zone or for different zones concurrently?
> > > 
> > > There was no change. They were allowed to call shrink_zone concurrently 
> > > before.
> > > 
> > 
> > Yes, there was.  Before the patchset, zone reclaim would not be able to 
> > call shrink_zone() on a zone that it is already being invoked for, 
> > regardless of where it was previous invoked from.  Now it is.
> 
> Right. I just wanted to make sure of this. The statement above 
> seems to indicate that there was a change to the concurrency of kswapd 
> and try_to_free_pages with one another.
> 

Ah, I see, I was trying to say that zone reclaim can now be called 
concurrently with kswapd and try_to_free_pages() in shrink_zone().  Thanks 
for pointing that out, it was poorly worded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
