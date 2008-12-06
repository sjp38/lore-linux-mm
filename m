Date: Sat, 6 Dec 2008 13:12:27 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] Fix incorrect use of loose in migrate.c
Message-ID: <20081206121227.GA6292@wotan.suse.de>
References: <20081205030807.32309.69191.stgit@marcab.local.tull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081205030807.32309.69191.stgit@marcab.local.tull.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Andrew <nick@nick-andrew.net>
Cc: Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 05, 2008 at 02:08:07PM +1100, Nick Andrew wrote:
> Fix incorrect use of loose in migrate.c
> 
> It should be 'lose', not 'loose'.
> 
> Signed-off-by: Nick Andrew <nick@nick-andrew.net>
> ---
> 
>  mm/migrate.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 1e0d6b2..7605b2b 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -514,7 +514,7 @@ static int writeout(struct address_space *mapping, struct page *page)
>  	/*
>  	 * A dirty page may imply that the underlying filesystem has
>  	 * the page on some queue. So the page must be clean for
> -	 * migration. Writeout may mean we loose the lock and the
> +	 * migration. Writeout may mean we lose the lock and the
>  	 * page state is no longer what we checked for earlier.
>  	 * At this point we know that the migration attempt cannot
>  	 * be successful.

I don't know... presumably we haven't just gone and lost the little
bugger. I mean, we were holding it one minute, then... gone?  Do we
have Alzheimer's? Unlikely. I think we loosed it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
