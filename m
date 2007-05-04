Date: Fri, 4 May 2007 14:27:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2
In-Reply-To: <1178310543.5236.43.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
References: <20070503022107.GA13592@kryten> <1178310543.5236.43.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Lee Schermerhorn wrote:

> On Wed, 2007-05-02 at 21:21 -0500, Anton Blanchard wrote:
> > An interesting bug was pointed out to me where we failed to allocate
> > hugepages evenly. In the example below node 7 has no memory (it only has
> > CPUs). Node 0 and 1 have plenty of free memory. After doing:
> 
> Here's my attempt to fix the problem [I see it on HP platforms as well],
> without removing the population check in build_zonelists_node().  Seems
> to work.

I think we need something like for_each_online_node for each node with
memory otherwise we are going to replicate this all over the place for 
memoryless nodes. Add a nodemap for populated nodes?

I.e.

for_each_mem_node?

Then you do not have to check the zone flags all the time. May avoid a lot 
of mess?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
