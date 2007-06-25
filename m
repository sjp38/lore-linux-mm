Date: Mon, 25 Jun 2007 06:06:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: slab allocators: MAX_ORDER one off fix
In-Reply-To: <20070623095334.51f80e94.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706250606060.5191@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706221100270.17293@schroedinger.engr.sgi.com>
 <20070623095334.51f80e94.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 23 Jun 2007, Andrew Morton wrote:

> I'm too lazy to look.  What are the consequences of deferring this to
> 2.6.23?  Oversized kmallocs will still get a runtime failure, so no real
> problem?

Right. No problem delaying this. Oversize kmallocs will return NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
