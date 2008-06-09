Date: Mon, 9 Jun 2008 07:10:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Collision of SLUB unique ID
In-Reply-To: <20080604234622.4b73289c.yoichi_yuasa@tripeaks.co.jp>
Message-ID: <Pine.LNX.4.64.0806090706230.29723@schroedinger.engr.sgi.com>
References: <20080604234622.4b73289c.yoichi_yuasa@tripeaks.co.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Jun 2008, Yoichi Yuasa wrote:

> I'm testing SLUB on Cobalt(MIPS machine).
> I got the following error messages at the boot time.
> 
> The Cobalt's ARCH_KMALLOC_MINALIGN is 128.
> At this time, kmalloc-192 unique ID has collided with kmalloc-256.

Hmmm... The system should alias the 192 byte cache to the 256 sized one. 

What kernel version is this? We could have broken this in 2.6.25 with the 
addtional flags that were added. But then it should be okay again for 
2.6.26-rcX which removed those additional flags. If this is indeed the 
case then we need a fix for stable and mainline is fine.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
