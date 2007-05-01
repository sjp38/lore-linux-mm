Date: Tue, 1 May 2007 21:19:09 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <20070501125559.9ab42896.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007, Andrew Morton wrote:
> On Tue, 1 May 2007 19:10:29 +0100 (BST)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > > Most of the rest of slub.  Will merge it all.
> > 
> > Merging slub already?  I'm surprised.
> 
> My thinking here is "does slub have a future".
> I think the answer is "yes",

I think I agree with that,
though it's a judgement I'd leave to you and others.

> so we're reasonably safe getting it into mainline for the finishing
> work.  The kernel.org kernel will still default to slab.
> 
> Does that sound wrong?

Yes, to me it does.  If it could be defaulted to on throughout the
-rcs, on every architecture, then I'd say that's "finishing work";
and we'd be safe knowing we could go back to slab in a hurry if
needed.  But it hasn't reached that stage yet, I think.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
