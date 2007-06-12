Date: Tue, 12 Jun 2007 14:45:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/3] NUMA: introduce node_memory_map
In-Reply-To: <20070612214249.GI3798@us.ibm.com>
Message-ID: <alpine.DEB.0.99.0706121443300.10250@chino.kir.corp.google.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.309078596@sgi.com>
 <alpine.DEB.0.99.0706121401060.5104@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706121407070.1850@schroedinger.engr.sgi.com>
 <alpine.DEB.0.99.0706121409170.5104@chino.kir.corp.google.com>
 <20070612213612.GH3798@us.ibm.com> <Pine.LNX.4.64.0706121437480.5196@schroedinger.engr.sgi.com>
 <20070612214249.GI3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Nishanth Aravamudan wrote:

> Yeah, I realize that -- but I also agree with David that
> 
> 	node_memory()
> 
> is not intuitive at all. And we've already admitted that a few of the
> macros in there are inconsistent already :)
> 

Creating new macros that conform to the others in terms of 
node_<single-word-here>() is great, but useless if it isn't readable in 
soruce code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
