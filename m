Date: Tue, 12 Jun 2007 14:39:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] NUMA: introduce node_memory_map
In-Reply-To: <20070612213612.GH3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706121437480.5196@schroedinger.engr.sgi.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.309078596@sgi.com>
 <alpine.DEB.0.99.0706121401060.5104@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706121407070.1850@schroedinger.engr.sgi.com>
 <alpine.DEB.0.99.0706121409170.5104@chino.kir.corp.google.com>
 <20070612213612.GH3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> Indeed, I did and (I like to think) I helped write the patches :)

The patches contain your signoff because of your authorship...

> We can keep
> 
> node_set_memory()
> node_clear_memory()
> 
> but change node_memory() to node_has_memory() ?

Hmmm.... That deviates from how the other node_xxx() things are so it 
disturbed my sense of order. We have no three word node_is/has_xxx yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
