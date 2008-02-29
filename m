Subject: Re: [patch 12/21] No Reclaim LRU Infrastructure
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <44c63dc40802282058h67f7597bvb614575f06c62e2c@mail.gmail.com>
References: <20080228192908.126720629@redhat.com>
	 <20080228192929.031646681@redhat.com>
	 <44c63dc40802282058h67f7597bvb614575f06c62e2c@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 29 Feb 2008 09:48:54 -0500
Message-Id: <1204296534.5311.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: minchan Kim <barrioskmc@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-02-29 at 13:58 +0900, minchan Kim wrote:
>         
>         +#ifdef CONFIG_NORECLAIM
>         +static inline void lru_cache_add_noreclaim(struct page *page)
>         +{
>         +       __lru_cache_add(page, LRU_NORECLAIM);
>         +}
>         +#else
>         +static inline void lru_cache_add_noreclaim(struct page *page)
>         +{
>         +       BUG("Noreclaim not configured, but page added
>         anyway?!");
>         +}
>         +#endif
>         +
> 
> BUG() can't take a argument. 

Right.  I don't have a clue how that got there :-(.

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
