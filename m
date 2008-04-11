Date: Fri, 11 Apr 2008 10:13:17 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 11/17] hugetlbfs: support larger than MAX_ORDER
Message-ID: <20080411081317.GQ10019@one.firstfloor.org>
References: <20080410170232.015351000@nick.local0.net> <20080410171101.551336000@nick.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080410171101.551336000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

>  	spin_lock(&hugetlb_lock);
> -	if (h->surplus_huge_pages_node[nid]) {
> +	if (h->surplus_huge_pages_node[nid] && h->order <= MAX_ORDER) {

As Andrew Hastings pointed out earlier this all needs to be h->order < MAX_ORDER
[got pretty much all the checks wrong off by one]. It won't affect anything
on x86-64 but might cause problems on archs which have exactly MAX_ORDER
sized huge pages.

>  		update_and_free_page(h, page);
>  		h->surplus_huge_pages--;
>  		h->surplus_huge_pages_node[nid]--;
> @@ -220,6 +221,9 @@ static struct page *alloc_fresh_huge_pag
>  {
>  	struct page *page;
>  
> +	if (h->order > MAX_ORDER)

>= etc.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
