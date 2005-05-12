Date: Thu, 12 May 2005 00:04:44 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: NUMA aware slab allocator V2
Message-Id: <20050512000444.641f44a9.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> This patch allows kmalloc_node to be as fast as kmalloc by introducing
>  node specific page lists for partial, free and full slabs.

This patch causes the ppc64 G5 to lock up fairly early in boot.  It's
pretty much a default config:
http://www.zip.com.au/~akpm/linux/patches/stuff/config-pmac

No serial port, no debug environment, but no useful-looking error messages
either.  See http://www.zip.com.au/~akpm/linux/patches/stuff/dsc02516.jpg

Also, the patch came through with all the "^ $" lines converted to
completely empty lines - probably your email client is trying to be clever.
Please send yourself a patch, check that it applies?

Finally, I do intend to merge up the various slab patches which are in -mm,
so if you could base further work on top of those it would simplify life,
thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
