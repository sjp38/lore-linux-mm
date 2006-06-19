Date: Mon, 19 Jun 2006 09:29:22 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: [patch] rfc: fix splice mapping race?
Message-ID: <20060619072921.GA4466@suse.de>
References: <20060618094157.GD14452@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060618094157.GD14452@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@engr.sgi.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 18 2006, Nick Piggin wrote:
> Hi, I would be interested in confirmation/comments for this patch.
> 
> I believe splice is unsafe to access the page mapping obtained
> when the page was unlocked: the page could subsequently be truncated
> and the mapping reclaimed (see set_page_dirty_lock comments).
> 
> Modify the remove_mapping precondition to ensure the caller has
> locked the page and obtained the correct mapping. Modify callers to
> ensure the mapping is the correct one.
> 
> In page migration, detect the missing mapping early and bail out if
> that is the case: the page is not going to get un-truncated, so
> retrying is just a waste of time.

splice bit looks good to me!

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
