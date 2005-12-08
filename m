Date: Wed, 7 Dec 2005 16:02:27 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC 1/3] Framework for accurate node based statistics
In-Reply-To: <43976949.8010205@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0512071559170.26144@schroedinger.engr.sgi.com>
References: <20051206182843.19188.82045.sendpatchset@schroedinger.engr.sgi.com>
 <439619F9.4030905@yahoo.com.au> <Pine.LNX.4.62.0512061536001.20580@schroedinger.engr.sgi.com>
 <439684C0.9090107@yahoo.com.au> <Pine.LNX.4.62.0512071026360.24516@schroedinger.engr.sgi.com>
 <43976949.8010205@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Dec 2005, Nick Piggin wrote:

> Christoph Lameter wrote:
> > On Wed, 7 Dec 2005, Nick Piggin wrote:
> > > Sorry, I think I meant: why don't you just use the "add all counters
> > > from all per-cpu of the node" in order to find the node-statistic?
> > which function is that?
> > 
> 
> I'm thinking of get_page_state_node... but that's not quite the same
> thing. I guess sum all per-CPU counters from all zones in the node,
> but that's going to be costly on big machines.

The per cpu counters count when a cpu did an allocation. They do not count 
on which node the allocation was done and are thereofre not useful to 
determine the memory use on one node.

> So I'm not sure, I guess I don't have any bright ideas... there is the
> batching approach used by current pagecache_acct - is something like
> that not sufficient either?

The framework provides a similar approach by keeping differential 
counters for each processor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
