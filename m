Date: Tue, 25 Sep 2007 14:17:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/5] mm: test and set zone reclaim lock before starting
 reclaim
In-Reply-To: <Pine.LNX.4.64.0709251413520.4831@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709251415490.32415@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
 <46F88DFB.3020307@linux.vnet.ibm.com> <alpine.DEB.0.9999.0709242129420.31515@chino.kir.corp.google.com> <Pine.LNX.4.64.0709251413520.4831@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007, Christoph Lameter wrote:

> On Mon, 24 Sep 2007, David Rientjes wrote:
> 
> > ZONE_RECLAIM_LOCKED will be cleared upon return from __zone_reclaim().
> 
> ZONE_RECLAIM_LOCKED means that one zone reclaim is already running and 
> other processes should not perform zone reclaim on the same zone. They 
> will instead fall back to allocate memory from zones that are not local.
> 

Yes, and that's still true.  But the point is that shrink_zone() can be 
called from different points (__zone_reclaim(), kswapd, 
try_to_free_pages(), balance_pgdat()) for a zone and it will not stop zone 
reclaim from being invoked on the same zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
