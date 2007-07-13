Subject: Re: [patch 00/12] NUMA: Memoryless node support V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com>
	 <20070713151431.GG10067@us.ibm.com>
	 <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 13 Jul 2007 13:20:39 -0400
Message-Id: <1184347239.5579.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-13 at 09:43 -0700, Christoph Lameter wrote:
> On Fri, 13 Jul 2007, Nishanth Aravamudan wrote:
> 
> > On 11.07.2007 [11:22:19 -0700], Christoph Lameter wrote:
> > > Changes V2->V3:
> > > - Refresh patches (sigh)
> > > - Add comments suggested by Kamezawa Hiroyuki
> > > - Add signoff by Jes Sorensen
> > 
> > Christoph, would it be possible to get the current patches up on
> > kernel.org in your people-space? That way I know I have the current
> > versions of these, including any fixlets that come by?
> 
> Lee: Would you repost the patches after testing them and fixing them up? 

I'm up to my eyeballs right now, setting up a large system for testing
VM scalability with Oracle.  I hope to have time early next week to test
your patches.  In a mail exchange between you and Andrew, you mentioned
that your memoryless-node patches are atop your slab defrag?  Shall I
test them that way?  Or try to rebase against the then current -mm tree?
I.e., what's the probability that the slab defrag patches make it into
-mm before the memoryless node patches?

> 
> You probably have somewhere to publish them? I will be on vacation next 
> week (and yes I will leave my laptop at home, somehow I have to get back 
> my sanity).

You mean in addition to posting?  I can stick a copy on my
free.linux.hp.com http site.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
