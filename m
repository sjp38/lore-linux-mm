Date: Tue, 6 Mar 2007 19:22:15 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 2/3] Large kmalloc pass through. Removal of large general
 slabs
In-Reply-To: <20070307024043.GT23311@waste.org>
Message-ID: <Pine.LNX.4.64.0703061920090.21854@schroedinger.engr.sgi.com>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
 <20070307023513.19658.81228.sendpatchset@schroedinger.engr.sgi.com>
 <20070307024043.GT23311@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, Matt Mackall wrote:

> I've been meaning to do this in SLOB as well. Perhaps it warrants
> doing in stock kmalloc? I've got a grand total of 18 of these objects
> here.

The number increases with the number numa nodes. We have had trouble with
the maximum kmalloc size before and this will get rid of it for good.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
