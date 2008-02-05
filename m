Date: Tue, 5 Feb 2008 11:07:36 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Support for statistics to help analyze allocator behavior
In-Reply-To: <20080205195511.b396ea4b.dada1@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0802051104520.12425@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0802050923220.14675@sbz-30.cs.Helsinki.FI> <47A81513.4010301@cosmosbay.com>
 <Pine.LNX.4.64.0802050952300.16488@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0802051007270.11705@schroedinger.engr.sgi.com>
 <20080205195511.b396ea4b.dada1@cosmosbay.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Eric Dumazet wrote:

> > Well we could do the same as for numa stats. Output the global count and 
> > then add
> > 
> > c<proc>=count
> > 
> 
> Yes, or the reverse, to avoid two loops and possible sum errors (Sum of 
> c<proc>=count different than the global count)

The numa output uses only one loop and so I think we could do the same 
here. Its good to have the global number first that way existing tools can 
simply read a number and get what they intuitively expect.

> Since text##_show is going to be too big, you could use one function 
> instead of several ones ?

Sure.

> (and char *buf is PAGE_SIZE, so you should add a limit ?)

Yes we must do so because support for 4k processors etc is on the horizon.

> Note I used for_each_possible_cpu() here instead of 'online' variant, or 
> stats might be corrupted when a cpu goes offline.

Hmmm.. We are thinking about freeing percpu areas when a cpu goes offline. 
So we would need to fold statistics into another cpu if this is a cocnern. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
