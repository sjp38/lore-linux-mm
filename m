Date: Mon, 14 Jul 2008 09:52:55 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] - GRU virtual -> physical translation
Message-ID: <20080714145255.GA23173@sgi.com>
References: <20080709191439.GA7307@sgi.com> <20080711121736.18687570.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080711121736.18687570.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 11, 2008 at 12:17:36PM -0700, Andrew Morton wrote:
> On Wed, 9 Jul 2008 14:14:39 -0500 Jack Steiner <steiner@sgi.com> wrote:
> 
> > Open code the equivalent to follow_page(). This eliminates the
> > requirement for an EXPORT of follow_page().
> 
> I'd prefer to export follow_page() - copying-n-pasting just to avoid
> exporting the darn thing is silly.

If follow_page() can be EXPORTed, I think that may make the most sense for
now.

> 
> > In addition, the code
> > is optimized for the specific case that is needed by the GRU and only
> > supports architectures supported by the GRU (ia64 & x86_64).
> 
> Unless you think that this alone justifies the patch?

No, at least not now. We don't have enough data yet to know if the additional
performance is worth having an optimized lookup routine. Currently the
focus is in making the driver functionally correct. Performance optimization
will be done later when we have a better understanding of the user apps that
will use the GRU.

_IF_ we agree to the export, what is the best way to send you the patches.
Incremental or an entirely new GRU V3 patch with all issues resolved?


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
