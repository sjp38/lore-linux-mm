Date: Tue, 11 Apr 2006 11:08:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm1 1/6] Migrate-on-fault - separate unmap
 from radix tree replace
In-Reply-To: <1144441333.5198.39.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0604111106550.878@schroedinger.engr.sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain>
 <1144441333.5198.39.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2006, Lee Schermerhorn wrote:

> +		struct page *page, int nr_refs)
> +{
> +	struct address_space *mapping = page_mapping(page);
> +        struct page **radix_pointer;
> +

Whitespace damage. Some other places as well.

>  /*
>   * Copy the page to its new location
> @@ -310,10 +338,11 @@ EXPORT_SYMBOL(migrate_page_copy);
>  int migrate_page(struct page *newpage, struct page *page)
>  {
>  	int rc;
> +	int nr_refs = 2;	/* cache + current */

Why the nr_refs variables if you do not modify them before passing them 
to the migration functions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
