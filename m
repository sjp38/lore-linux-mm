Date: Thu, 8 Nov 2007 12:01:24 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 02/23] SLUB: Rename NUMA defrag_ratio to remote_node_defrag_ratio
In-Reply-To: <20071108194735.GW19691@waste.org>
Message-ID: <Pine.LNX.4.64.0711081159120.9966@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <20071107011226.844437184@sgi.com>
 <20071108145044.GB2591@skynet.ie> <20071108172548.GW17536@waste.org>
 <Pine.LNX.4.64.0711081116060.9279@schroedinger.engr.sgi.com>
 <20071108194735.GW19691@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Mel Gorman <mel@skynet.ie>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Nov 2007, Matt Mackall wrote:

> Not really. drivers/char/random.c does:
> 
> __get_cpu_var(trickle_count)++ & 0xfff

That is incremented on each call to add_timer_randomness. Not a high 
enough resolution there. I guess I am stuck with get_cycles().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
