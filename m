Date: Wed, 13 Jun 2007 15:51:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
In-Reply-To: <1181758874.6148.73.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706131550520.32399@schroedinger.engr.sgi.com>
References: <20070612032055.GQ3798@us.ibm.com>  <1181660782.5592.50.camel@localhost>
 <20070612172858.GV3798@us.ibm.com>  <1181674081.5592.91.camel@localhost>
 <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
 <1181677473.5592.149.camel@localhost>  <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
  <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
 <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost>
 <20070613175802.GP3798@us.ibm.com> <1181758874.6148.73.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jun 2007, Lee Schermerhorn wrote:

> Yep.  I'm testing the stack "as is" now.  If it doesn't spread the huge
> pages evenly because of our funky DMA-only node, I'll post a fix up
> patch for consideration.

Note that the memory from your DMA only node is allocated without 
requiring DMA memory. We just fall back in the allocation to DMA memory.
Thus you do not need special handling as far as I can tell.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
