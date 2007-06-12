Date: Mon, 11 Jun 2007 19:53:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Add populated_map to account for memoryless nodes
In-Reply-To: <20070612112757.e2d511e0.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706111952580.25390@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com> <20070612112757.e2d511e0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, KAMEZAWA Hiroyuki wrote:

> On Mon, 11 Jun 2007 13:27:28 -0700
> Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > Split up Lee and Anton's original patch
> > (http://marc.info/?l=linux-mm&m=118133042025995&w=2), to allow for the
> > populated_map changes to go in on their own.
> > 
> > Add a populated_map nodemask to indicate a node has memory or not. We
> > have run into a number of issues (in practice and in code) with
> > assumptions about every node having memory. Having this nodemask allows
> > us to fix these issues; in particular, THISNODE allocations will come
> > from the node specified, only, and the INTERLEAVE policy will be able to
> > do the right thing with memoryless nodes.
> > 
> Thank you, I like this work.
> 
> > +extern nodemask_t node_populated_map;
> please add /* node has memory */ here.
> 
> I don't think "populated node" means "node-with-memory" if there is no comments.

What else could it mean?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
