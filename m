Date: Thu, 26 Apr 2007 23:32:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 03/10] SLUB: debug printk cleanup
Message-Id: <20070426233221.d22049bc.akpm@linux-foundation.org>
In-Reply-To: <20070427042907.998009077@sgi.com>
References: <20070427042655.019305162@sgi.com>
	<20070427042907.998009077@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Apr 2007 21:26:58 -0700 clameter@sgi.com wrote:

> Set up a new function slab_err in order to report errors consistently.
> 
> Consistently report corrective actions taken by SLUB by a printk starting
> with @@@.
> 
> Fix locations where there is no 0x in front of %p.

This patch splatters itself all over preceding patches so our patch
presentation gets screwed up.  

We already have one damned great impermeable barrier right in the middle of
all the slub patches, namely
make-page-private-usable-in-compound-pages-v1.patch.

I had a go at splitting this patch up into useful sections but I made a
mess of it.  I'll drop it.

Please, prepare finely-grained patches at this stage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
