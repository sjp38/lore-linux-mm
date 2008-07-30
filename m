Received: by py-out-1112.google.com with SMTP id f31so128572pyh.20
        for <linux-mm@kvack.org>; Wed, 30 Jul 2008 13:31:54 -0700 (PDT)
Message-ID: <2f11576a0807301331re913516k2f4782b4f3f4d5a@mail.gmail.com>
Date: Thu, 31 Jul 2008 05:31:53 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] unevictable lru: Remember page's active state
In-Reply-To: <20080730200624.24272.7234.sendpatchset@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
	 <20080730200624.24272.7234.sendpatchset@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

> @@ -483,12 +483,12 @@ int remove_mapping(struct address_space
>  void putback_lru_page(struct page *page)
>  {
>        int lru;
> +       int active = !!TestClearPageActive(page);
>        int was_unevictable = PageUnevictable(page);
>
>        VM_BUG_ON(PageLRU(page));
>
>  redo:
> -       lru = !!TestClearPageActive(page);
>        ClearPageUnevictable(page);
>
>        if (page_evictable(page, NULL)) {
> @@ -498,7 +498,7 @@ redo:
>                 * unevictable page on [in]active list.
>                 * We know how to handle that.
>                 */
> -               lru += page_is_file_cache(page);
> +               lru = active + page_is_file_cache(page);
>                lru_cache_add_lru(page, lru);
>        } else {

Indeed.

          Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
