Date: Tue, 27 Dec 2005 12:35:30 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [patch 3/3] mm: NUMA slab -- minor optimizations
In-Reply-To: <43B07FE9.4000803@colorfullife.com>
Message-ID: <Pine.LNX.4.62.0512271229080.27185@schroedinger.engr.sgi.com>
References: <20051129085049.GA3573@localhost.localdomain>
 <20051129085456.GC3573@localhost.localdomain> <43B07FE9.4000803@colorfullife.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Alok Kataria <alokk@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Dec 2005, Manfred Spraul wrote:

> Isn't that a bug? What prevents an interrupt from occuring after the
> spin_lock() and then causing a deadlock on cachep->spinlock?

Right. cache_grow() may be called when doing slab allocations in an 
interrupt and it takes the lock in order to modify colour_next. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
