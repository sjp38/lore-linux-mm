Date: Fri, 8 Jun 2007 08:36:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Allow PAGE_OWNER to be set on any architecture
In-Reply-To: <20070608125349.GA8444@skynet.ie>
Message-ID: <Pine.LNX.4.64.0706080833560.32416@schroedinger.engr.sgi.com>
References: <20070608125349.GA8444@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: alexn@telia.com, akpm@linux-foundation.org, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007, Mel Gorman wrote:

> In situations where CONFIG_HOLES_IN_ZONES is set (IA64 with VIRTUAL_MEM_MAP),
> there may be cases where pages allocated within a MAX_ORDER_NR_PAGES block
> of pages may not be displayed in /proc/page_owner if the hole is at the
> start of the block. Addressing this would be quite complex, perform slowly
> and is of no clear benefit.

Note that CONFIG_HOLES_IN_ZONES and IA64 VIRTUAL_MEM_MAP may be going 
away. Andy Whitcroft has a patchset that implements virtual memmap 
support under sparse and that would allow us to get rid of this.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
