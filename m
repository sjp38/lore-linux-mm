Date: Thu, 14 Jun 2007 08:51:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
In-Reply-To: <1181832930.5410.37.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706140849170.29460@schroedinger.engr.sgi.com>
References: <20070612204843.491072749@sgi.com>  <20070612205738.548677035@sgi.com>
 <1181769033.6148.116.camel@localhost>  <Pine.LNX.4.64.0706131535200.32399@schroedinger.engr.sgi.com>
  <1181830705.5410.13.camel@localhost>  <Pine.LNX.4.64.0706140721510.28544@schroedinger.engr.sgi.com>
 <1181832930.5410.37.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, Lee Schermerhorn wrote:

> > It is able to handle NULLs during usual operations but not during bootstrap.
> 
> ???  it has to handle memoryless nodes, right?  if so, why can't it
> handle alloc_pages_node('THISNODE,...) returning NULL?  Too late in the
> process?

It should not call alloc_pages_node for a node that has no memory during 
bootstrap.

> Or do you mean that GPF_THISNODE should return memory from the lower
> zones, if it satisfies the order requirement?  Your custom 'thisnode'
> zonelist will enable this, right?  That would work for my particular
> config of my platform, but on a larger platform, I'd have a larger DMA
> zone and wouldn't want hugetlb pages coming from there.  

Right. The fixes here are for the general vm and not for hugetlb. They are 
definitely not HP platform specific.

> I guess that in the long run, I need to hope that Nish's per node huge
> page attribute goes in. Then, we can provide a fancy script to configure
> huge pages on a specific set of nodes, rather than relying on the kernel
> to distribute them evenly across the set of nodes that "make sense" for
> the given platform.

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
