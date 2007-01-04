Date: Thu, 4 Jan 2007 15:52:38 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [2.6 patch] the scheduled find_trylock_page() removal
Message-ID: <20070104155238.GA5648@infradead.org>
References: <20070102215735.GD20714@stusta.de> <459C8833.7080500@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <459C8833.7080500@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Adrian Bunk <bunk@stusta.de>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 04, 2007 at 03:53:07PM +1100, Nick Piggin wrote:
> Adrian Bunk wrote:
> >This patch contains the scheduled find_trylock_page() removal.
> >
> >Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> I guess I don't have a problem with this going into -mm and making its way
> upstream sometime after the next release.
> 
> I would normally say it is OK to stay for another year because it is so
> unintrusive, but I don't like the fact it doesn't give one an explicit ref
> on the page -- it could be misused slightly more easily than find_lock_page
> or find_get_page.
> 
> Anyone object? Otherwise:

Just kill it.  There's absolutely no point in keeping dead code around.
It's bad enough we keep such things around for half a year.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
