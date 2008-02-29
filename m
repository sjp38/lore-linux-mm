Date: Fri, 29 Feb 2008 11:43:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 3/8] slub: Update statistics handling for variable order
 slabs
In-Reply-To: <47C7C972.9010408@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0802291141440.11084@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com> <20080229044818.999367120@sgi.com>
 <47C7C972.9010408@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008, Pekka Enberg wrote:

> Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

Hmmm... I get some weird numbers when I use slabinfo but cannot spot the 
issue. Could you look a bit closer at this? In particular at the slabinfo 
emulation?
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
