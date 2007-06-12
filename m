Date: Tue, 12 Jun 2007 15:26:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] NUMA: introduce node_memory_map
In-Reply-To: <20070612214249.GI3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706121523470.6942@schroedinger.engr.sgi.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.309078596@sgi.com>
 <alpine.DEB.0.99.0706121401060.5104@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706121407070.1850@schroedinger.engr.sgi.com>
 <alpine.DEB.0.99.0706121409170.5104@chino.kir.corp.google.com>
 <20070612213612.GH3798@us.ibm.com> <Pine.LNX.4.64.0706121437480.5196@schroedinger.engr.sgi.com>
 <20070612214249.GI3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, pj@sgi.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Nishanth Aravamudan wrote:

> is not intuitive at all. And we've already admitted that a few of the
> macros in there are inconsistent already :)

I do not want to add another inconsistency.

if (node_memory(node))

is pretty clear as far as I can tell.

Some of the macros in include/linux/nodemask.h are inconsistent. How can 
we make those consistent. Could you come up with a consistent naming 
scheme? Add the explanation for that scheme.

But that should be a separate patch. And the patch would have to change 
all uses of those macros in the kernel source tree.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
