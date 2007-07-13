Date: Fri, 13 Jul 2007 10:23:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/12] NUMA: Memoryless node support V3
In-Reply-To: <1184347239.5579.3.camel@localhost>
Message-ID: <Pine.LNX.4.64.0707131022140.22340@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com>  <20070713151431.GG10067@us.ibm.com>
  <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
 <1184347239.5579.3.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007, Lee Schermerhorn wrote:

> I'm up to my eyeballs right now, setting up a large system for testing
> VM scalability with Oracle.  I hope to have time early next week to test
> your patches.  In a mail exchange between you and Andrew, you mentioned
> that your memoryless-node patches are atop your slab defrag?  Shall I
> test them that way?  Or try to rebase against the then current -mm tree?

You can skip the slab defrag. I posted a rediffed patch in my response 
to Andrew. Use that one.

> I.e., what's the probability that the slab defrag patches make it into
> -mm before the memoryless node patches?

No idea. Use the patch that does not rely on slab defrag.

> > You probably have somewhere to publish them? I will be on vacation next 
> > week (and yes I will leave my laptop at home, somehow I have to get back 
> > my sanity).
> 
> You mean in addition to posting?  I can stick a copy on my
> free.linux.hp.com http site.

Yes. Seems that many people want that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
