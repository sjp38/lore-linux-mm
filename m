Date: Tue, 12 Jun 2007 11:39:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Add populated_map to account for memoryless nodes
In-Reply-To: <20070612173521.GX3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706121138050.30754@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <1181657433.5592.11.camel@localhost> <20070612173521.GX3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Nishanth Aravamudan wrote:

> > Mea culpa.  Our platforms have a [pseudo-]node with just O(1G) memory
> > all in zone DMA.  That node can't look populated for allocating huge
> > pages.
> 
> Because you don't want to use up any of the DMA pages, right? That seems
> *very* platform specific. And it doesn't seem right to make common code
> more complicated for one platform. Maybe there isn't a better solution,
> but I'd like to mull it over.

Right. Please Lee be generic and avoid the exceptional cases.

> > Maybe we can just exclude zone DMA from the populated map?
> 
> Maybe I don't know enough about NUMA and such, but I'm not sure I
> understand how this would make it a populated map anymore?
> 
> Maybe we need two maps, really?

No need. If you want to exclude a node from huge pages then you need 
to use the patch that allows per node huge page specifications and set 
the number of huge pages for that node to zero.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
