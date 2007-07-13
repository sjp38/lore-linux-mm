Subject: Re: [patch 00/12] NUMA: Memoryless node support V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707131022140.22340@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com>
	 <20070713151431.GG10067@us.ibm.com>
	 <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
	 <1184347239.5579.3.camel@localhost>
	 <Pine.LNX.4.64.0707131022140.22340@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 13 Jul 2007 15:22:28 -0400
Message-Id: <1184354548.5579.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-13 at 10:23 -0700, Christoph Lameter wrote:
> On Fri, 13 Jul 2007, Lee Schermerhorn wrote:
> 
> > I'm up to my eyeballs right now, setting up a large system for testing
> > VM scalability with Oracle.  I hope to have time early next week to test
> > your patches.  In a mail exchange between you and Andrew, you mentioned
> > that your memoryless-node patches are atop your slab defrag?  Shall I
> > test them that way?  Or try to rebase against the then current -mm tree?
> 
> You can skip the slab defrag. I posted a rediffed patch in my response 
> to Andrew. Use that one.
> 

OK, I see the rebased patch 7/12 [SLUB support] in your response to
Andrew.  

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
