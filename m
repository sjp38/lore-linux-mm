Date: Tue, 12 Jun 2007 12:22:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] Add populated_map to account for memoryless nodes
In-Reply-To: <1181675840.5592.123.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706121220580.3240@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com>  <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
  <1181657940.5592.19.camel@localhost>  <Pine.LNX.4.64.0706121143530.30754@schroedinger.engr.sgi.com>
 <1181675840.5592.123.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Lee Schermerhorn wrote:

> On Tue, 2007-06-12 at 11:45 -0700, Christoph Lameter wrote:
> Now, Nish is proposing to use the populated map to filter policy-based
> interleaved allocations.  My definition of populated map won't work for
> that.  So, YOU are the one changing the definition.  I'm OK with that if
> it solves a more generic problem.  My patch hadn't gone in anyway.

Ok. So how about renaming the populated_map to

node_memory_map

so that its clear that this is a map of node with memory?

GFP_THISNODE needs this map to fail on memoryless nodes.

> Yes, but I didn't want to stick #ifdefs in the functions if I didn't
> have to.  But, it's a moot point.  After looking at it more, I've
> decided there may be no definition of populated map that works reliably
> for huge page allocation on all of the platform configurations.
> However, if GFP_THISNODE guarantees no off-node allocations, that may do
> the trick.

It can do that if the populated map works the right way.... circle is 
closing ... I can sent out a patchset in a few minutes that fixes the 
GFP_THISNODE issue and introduces node_memory_map.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
