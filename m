Date: Fri, 1 Dec 2006 08:32:35 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Slab: Better fallback allocation behavior
In-Reply-To: <20061201123205.GA3528@skynet.ie>
Message-ID: <Pine.LNX.4.64.0612010829260.17445@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611291659390.18762@schroedinger.engr.sgi.com>
 <20061201123205.GA3528@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Dec 2006, Mel Gorman wrote:

> Hi Christoph,
> 
> On (29/11/06 17:01), Christoph Lameter didst pronounce:
> > Currently we simply attempt to allocate from all allowed nodes using 
> > GFP_THISNODE.
> 
> I thought GFP_THISNODE meant we never fallback to other nodes and no policies
> are ever applied.

That is __GFP_THISNODE alone. GFP_THISNODE is combination of flags used to 
get a page if there is one available on that node. These are necessary so 
that kernel subsystems (like the slab) can manage their own locality by 
placing node specific objects in per node lists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
