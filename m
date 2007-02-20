Date: Tue, 20 Feb 2007 11:00:05 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] free swap space when (re)activating page
Message-ID: <20070220190005.GQ21484@holomorphy.com>
References: <45D63445.5070005@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45D63445.5070005@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 16, 2007 at 05:46:29PM -0500, Rik van Riel wrote:
> The attached patch does what I described in the other thread, it
> makes the pageout code free swap space when swap is getting full,
> by taking away the swap space from pages that get moved onto or
> back onto the active list.
> In some tests on a system with 2GB RAM and 1GB swap, it kept the
> free swap at 500MB for a 2.3GB qsbench, while without the patch
> over 950MB of swap was in use all of the time.
> This should give kswapd more flexibility in what to swap out.
> What do you think?
> Signed-off-by: Rik van Riel <riel@redhat.com>

I would call this a bugfix, not an optimization.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
