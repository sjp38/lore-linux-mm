Date: Wed, 14 Dec 2005 19:29:04 -0800
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC][PATCH 1/6] Create Critical Page Pool
Message-ID: <20051215032904.GB11856@waste.org>
References: <439FCECA.3060909@us.ibm.com> <439FCF4E.3090202@us.ibm.com> <Pine.LNX.4.63.0512140829410.2723@cuia.boston.redhat.com> <43A047A1.9030308@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43A047A1.9030308@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, pavel@suse.cz, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 14, 2005 at 08:26:09AM -0800, Matthew Dobson wrote:
> Rik van Riel wrote:
> > On Tue, 13 Dec 2005, Matthew Dobson wrote:
> > 
> > 
> >>Create the basic Critical Page Pool.  Any allocation specifying 
> >>__GFP_CRITICAL will, as a last resort before failing the allocation, try 
> >>to get a page from the critical pool.  For now, only singleton (order 0) 
> >>pages are supported.
> > 
> > 
> > How are you going to limit the number of GFP_CRITICAL
> > allocations to something smaller than the number of
> > pages in the pool ?
> 
> We can't.
> 
> 
> > Unless you can do that, all guarantees are off...
> 
> Well, I was careful not to use the word guarantee in my post. ;)  The idea
> is not to offer a 100% guarantee that the pool will never be exhausted.
> The idea is to offer a pool that, sized appropriately, offers a very good
> chance of surviving your emergency situation.  The definition of what is a
> critical allocation and what the emergency situation is left intentionally
> somewhat vague, so as to offer more flexibility.  For our use, certain
> networking allocations are critical and our emergency situation is a 2
> minute window of potential exreme memory pressure.  For others it could be
> something completely different, but the expectation is that the emergency
> situation would be of a finite time, since the pool is a fixed size.

What's your plan for handling the no-room-to-receive-ACKs problem? 

Without addressing this, this is a non-starter for most of the network
OOM problems I care about.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
