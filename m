Date: Tue, 1 May 2007 12:55:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22 -mm merge plans: slub
Message-Id: <20070501125559.9ab42896.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007 19:10:29 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> > Most of the rest of slub.  Will merge it all.
> 
> Merging slub already?  I'm surprised.

My thinking here is "does slub have a future".  I think the answer is
"yes", so we're reasonably safe getting it into mainline for the finishing
work.  The kernel.org kernel will still default to slab.

Does that sound wrong?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
