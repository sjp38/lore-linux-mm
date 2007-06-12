Date: Tue, 12 Jun 2007 14:34:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/3] NUMA: introduce node_memory_map
In-Reply-To: <Pine.LNX.4.64.0706121426020.2322@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.99.0706121430240.8937@chino.kir.corp.google.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.309078596@sgi.com>
 <alpine.DEB.0.99.0706121401060.5104@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706121407070.1850@schroedinger.engr.sgi.com>
 <alpine.DEB.0.99.0706121409170.5104@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706121426020.2322@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Christoph Lameter wrote:

> > > On Tue, 12 Jun 2007, David Rientjes wrote:
> > > 
> > > > >   * int node_online(node)		Is some node online?
> > > > >   * int node_possible(node)		Is some node possible?
> > > > > + * int node_memory(node)		Does a node have memory?
> > > > >   *
> > > > 
> > > > This name doesn't make sense; wouldn't node_has_memory() be better?
> > > 
> > > node_set_has_memory and node_clear_has_memory sounds a bit strange.
> > > 
> > 
> > This will probably be one of those things that people see in the source 
> > and have to look up everytime.  node_has_memory() is straight-forward and 
> > to the point.
> 
> But node_possible is similar to node_memory.
> 
> Would you also prefer node_is_possible over node_possible?
> 
> node_is_online?
> 

I think the problem is that online and possible are adverbs and 
adjectives, respectively, and memory is a noun.  That's why when it 
appears in source code, it doesn't make a lot of sense for node_memory to 
return a boolean value.  I suspect it would return the memory, whatever 
that is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
