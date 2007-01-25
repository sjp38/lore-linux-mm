Date: Wed, 24 Jan 2007 21:52:09 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/5] Add a map to to track dirty pages per node
In-Reply-To: <45B81E5B.1090505@google.com>
Message-ID: <Pine.LNX.4.64.0701242143200.13327@schroedinger.engr.sgi.com>
References: <20070123185242.2640.8367.sendpatchset@schroedinger.engr.sgi.com>
 <20070123185248.2640.87514.sendpatchset@schroedinger.engr.sgi.com>
 <45B81E5B.1090505@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: akpm@osdl.org, Paul Menage <menage@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jan 2007, Ethan Solomita wrote:

>    The below addition makes us skip inodes outside of our dirty nodes. Do we
> want this even with WB_SYNC_ALL and WB_SYNC_HOLD? It seems that callers from
> sync_inodes_sb(), which are the ones that pass in those options, may want to
> know that everything is written.

A constraint on the nodes requires setting wbc.nodes. I could not find a 
writeback_control setup that uses either of those flags and also sets 
wbc.nodes.

And WB_SYNC_ALL is already used with another constraints on a 
mapping to only partially sync.

If a caller in the future sets wbc.nodes plus either of those options then 
it is an attempt to perform these operations only on a subset of nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
