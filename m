Message-ID: <41813FCD.3070503@us.ibm.com>
Date: Thu, 28 Oct 2004 11:51:57 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: migration cache, updated
References: <20041026092535.GE24462@logos.cnet> <20041026.230110.21315175.taka@valinux.co.jp> <20041026122419.GD27014@logos.cnet> <20041027.224837.118287069.taka@valinux.co.jp> <20041028151928.GA7562@logos.cnet> <20041028160520.GB7562@logos.cnet>
In-Reply-To: <20041028160520.GB7562@logos.cnet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, iwamoto@valinux.co.jp, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> +static inline int PageMigration(struct page *page)
> +{
> +        swp_entry_t entry;
> +
> +        if (!PageSwapCache(page))
> +                return 0;
> +
> +        entry.val = page->private;
> +
> +        if (swp_type(entry) != MIGRATION_TYPE)
> +                return 0;
> +
> +        return 1;
> +}

Don't we usually try to keep the Page*() operations to be strict 
page->flags checks?  Should this be page_migration() or something 
similar instead?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
