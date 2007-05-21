Date: Mon, 21 May 2007 13:52:08 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 00/10] Slab defragmentation V2
In-Reply-To: <20070518181040.465335396@sgi.com>
Message-ID: <Pine.LNX.4.64.0705211349090.28830@blonde.wat.veritas.com>
References: <20070518181040.465335396@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2007, clameter@sgi.com wrote:
> Hugh: Could you have a look at this? There is lots of critical locking
> here....

Sorry, Christoph, no: I've far too many bugs to chase, and unfulfilled
promises outstanding: this is not something I can spend time on - sorry.

Hugh

> Support for Slab defragmentation and targeted reclaim. The current
> state of affairs is that a large portion of inode and dcache slab caches
> can be effectively reclaimed. The remaining problems are:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
