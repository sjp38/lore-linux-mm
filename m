Date: Mon, 27 Jun 2005 09:17:10 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [rfc] lockless pagecache
Message-ID: <20050627131710.GC13945@kvack.org>
References: <42BF9CD1.2030102@yahoo.com.au> <20050627004624.53f0415e.akpm@osdl.org> <42BFB287.5060104@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42BFB287.5060104@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 27, 2005 at 06:02:15PM +1000, Nick Piggin wrote:
> However I think for Oracle and others that use shared memory like
> this, they are probably not doing linear access, so that would be a
> net loss. I'm not completely sure (I don't have access to real loads
> at the moment), but I would have thought those guys would have looked
> into fault ahead if it were a possibility.

Shared memory overhead doesn't show up on any of the database benchmarks 
I've seen, as they tend to use huge pages that are locked in memory, and 
thus don't tend to access the page cache at all after ramp up.

		-ben
-- 
"Time is what keeps everything from happening all at once." -- John Wheeler
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
