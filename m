Date: Tue, 10 Jun 2008 12:00:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/7] powerpc: lockless get_user_pages_fast
In-Reply-To: <20080605094826.128415000@nick.local0.net>
Message-ID: <Pine.LNX.4.64.0806101159110.17798@schroedinger.engr.sgi.com>
References: <20080605094300.295184000@nick.local0.net>
 <20080605094826.128415000@nick.local0.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Jun 2008, npiggin@suse.de wrote:

> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -244,7 +244,7 @@ static inline int put_page_testzero(stru
>   */
>  static inline int get_page_unless_zero(struct page *page)
>  {
> -	VM_BUG_ON(PageTail(page));
> +	VM_BUG_ON(PageCompound(page));
>  	return atomic_inc_not_zero(&page->_count);
>  }

This is reversing the modification to make get_page_unless_zero() usable 
with compound page heads. Will break the slab defrag patchset.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
