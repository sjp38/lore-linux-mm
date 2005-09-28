Date: Wed, 28 Sep 2005 14:55:14 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [patch] Reset the high water marks in CPUs pcp list
In-Reply-To: <15630000.1127942318@flay>
Message-ID: <Pine.LNX.4.62.0509281454210.15902@schroedinger.engr.sgi.com>
References: <20050928105009.B29282@unix-os.sc.intel.com>
 <Pine.LNX.4.62.0509281259550.14892@schroedinger.engr.sgi.com>
 <15630000.1127942318@flay>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: "Seth, Rohit" <rohit.seth@intel.com>, akpm@osdl.org, linux-mm@kvack.org, Mattia Dongili <malattia@linux.it>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Sep 2005, Martin J. Bligh wrote:

> >> Recent changes in page allocations for pcps has increased the high watermark for these lists.  This has resulted in scenarios where pcp lists could be having bigger number of free pages even under low memory conditions. 
> >> 
> >>  	[PATCH]: Reduce the high mark in cpu's pcp lists.
> > 
> > There is no need for such a patch. The pcp lists are regularly flushed.
> > See drain_remote_pages.
> 
> That's only retrieving pages which have migrated off-node, is it not?

Its freeing all pages in off node pcps. There is no page migration 
in the current kernels.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
