Subject: Re: [RFC PATCH] discarding swap
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0809102015230.16131@blonde.site>
References: <Pine.LNX.4.64.0809092222110.25727@blonde.site>
	 <20080910173518.GD20055@kernel.dk>
	 <Pine.LNX.4.64.0809102015230.16131@blonde.site>
Content-Type: text/plain; charset=UTF-8
Date: Wed, 10 Sep 2008 14:28:37 -0700
Message-Id: <1221082117.13621.25.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-09-10 at 20:51 +0100, Hugh Dickins wrote:
> [PATCH] block: adjust blkdev_issue_discard for swap

blkdev_issue_discard() is for naA?ve callers who don't want to have to
think about barriers. You might benefit from issuing discard requests
without an implicit softbarrier, for swap.

Of course, you then have to ensure that a discard can't still be
in-flight and actually happen _after_ a subsequent write to that page.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
