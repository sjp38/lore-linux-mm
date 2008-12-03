Date: Wed, 3 Dec 2008 12:52:53 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 10/9] swapfile: change discard pgoff_t to sector_t
In-Reply-To: <20081202164732.1d6d0997.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0812031251260.6817@blonde.anvils>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
 <Pine.LNX.4.64.0811252140230.17555@blonde.site> <Pine.LNX.4.64.0811252145190.20455@blonde.site>
 <Pine.LNX.4.64.0812010028040.10131@blonde.site> <20081202164732.1d6d0997.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dwmw2@infradead.org, jens.axboe@oracle.com, matthew@wil.cx, joern@logfs.org, James.Bottomley@HansenPartnership.com, djshin90@gmail.com, teheo@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Dec 2008, Andrew Morton wrote:
> On Mon, 1 Dec 2008 00:29:41 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > -		pgoff_t nr_blocks = se->nr_pages << (PAGE_SHIFT - 9);
> > +		sector_t nr_blocks = se->nr_pages << (PAGE_SHIFT - 9);
> 
> but, but, that didn't change anything?  se->nr_pages must be cast to
> sector_t?

I'm squirming, you are right, thanks for fixing it up.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
