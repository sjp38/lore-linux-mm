Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <29495f1d0707201335u5fbc9565o2a53a18e45d8b28@mail.gmail.com>
References: <20070713151621.17750.58171.stgit@kernel>
	 <20070713151717.17750.44865.stgit@kernel>
	 <20070713130508.6f5b9bbb.pj@sgi.com>
	 <1184360742.16671.55.camel@localhost.localdomain>
	 <20070713143838.02c3fa95.pj@sgi.com>
	 <29495f1d0707171642t7c1a26d7l1c36a896e1ba3b47@mail.gmail.com>
	 <1184769889.5899.16.camel@localhost>
	 <29495f1d0707180817n7a5709dcr78b641a02cb18057@mail.gmail.com>
	 <1184774524.5899.49.camel@localhost> <20070719015231.GA16796@linux-sh.org>
	 <29495f1d0707201335u5fbc9565o2a53a18e45d8b28@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 20 Jul 2007 16:53:58 -0400
Message-Id: <1184964838.9651.70.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Paul Jackson <pj@sgi.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, clameter@sgi.com, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-20 at 13:35 -0700, Nish Aravamudan wrote:
> On 7/18/07, Paul Mundt <lethal@linux-sh.org> wrote:
<snip>
> > It would be quite nice to have some way to have nodes opt-in to the sort
> > of behaviour they're willing to tolerate. Some nodes are never going to
> > tolerate spreading of any sort, hugepages, and so forth. Perhaps it makes
> > more sense to have some flags in the pgdat where we can more strongly
> > type the sort of behaviour the node is willing to put up with (or capable
> > of supporting), at least in this case the nodes that explicitly can't
> > cope are factored out before we even get to cpuset constraints (plus this
> > gives us a hook for setting up the interleave nodes in both the system
> > init and default policies). Thoughts?
> 
> I guess I don't understand which nodes you're talking about now? How
> do you spread across any particular single node (how I read "Some
> nodes are never going to tolerate spreading of any sort")? Or do you
> mean that some cpusets aren't going to want to spread (interleave?).
> 
> Oh, are you trying to say that some nodes should be dropped from
> interleave masks (explicitly excluded from all possible interleave
> masks)? What kind of nodes would these be? We're doing something
> similar to deal with memoryless nodes, perhaps it could be
> generalized?

If that's what Paul means [and I think it is, based on a converstation
at OLS], I have a similar requirement.  I'd like to be able to specify,
on the command line, at least [run time reconfig not a hard requirement]
nodes to be excluded from interleave masks, including the hugetlb
allocation mask [if this is different from the regular interleaving
nodemask].  

And, I agree, I think we can add another node_states[] entry or two to
hold these nodes.  I'll try to work up a patch next week if noone beats
me to it.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
