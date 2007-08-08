Date: Wed, 8 Aug 2007 13:04:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 02/14] Memoryless nodes: introduce mask of nodes with
 memory
In-Reply-To: <20070808195514.GE16588@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0708081303280.14275@schroedinger.engr.sgi.com>
References: <20070804030100.862311140@sgi.com> <20070804030152.843011254@sgi.com>
 <20070808123804.d3b3bc79.akpm@linux-foundation.org> <20070808195514.GE16588@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kxr@sgi.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Bob Picco <bob.picco@hp.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007, Nishanth Aravamudan wrote:

> > but we continue to have some significant testing issues out there.		
> 
> This would be because the patch that Christoph submitted here is not the
> same as the patch that Mel and I tested...There was no
> check_for_regular_memory() function in the kernels I was building.

Right. I added that to #ifdef out the HIGHMEM/NORMAL distinction for 
regular NUMA boxes. I only tested on regular NUMA and not on NUMAQ.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
