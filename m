Subject: Re: [RFC/PATCH] free_area[] bitmap elimination[0/3]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <412B32D1.10005@jp.fujitsu.com>
References: <412B32D1.10005@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093366431.1009.28.camel@nighthawk>
Mime-Version: 1.0
Date: Tue, 24 Aug 2004 09:53:52 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>, Hirokazu Takahashi <taka@valinux.co.jp>, ncunningham@linuxmail.org
List-ID: <linux-mm.kvack.org>

On Tue, 2004-08-24 at 05:21, Hiroyuki KAMEZAWA wrote:
>  /*
> + * These macros are used in alloc_pages()/free_pages(), buddy allocator.
> + * page_order(page) returns an order of a free page in buddy allocator.
> + * set_page_order(page, order) sets an order of a free page in buddy allocator.
> + * Invalidate_page_order() invalidates order information for avoiding
> + * conflicts of pages in transition state.
> + *
> + * this is used with PG_private flag
> + */ 
> +#define set_page_order(page,order)\
> +        do {\
> +            (page)->private = (order);\
> +            SetPagePrivate((page));\
> +        } while(0)
> +#define invalidate_page_order(page) ClearPagePrivate((page))
> +#define page_order(page) ((page)->private)
> +
> +/*

Can these be made into static inline functions instead of macros?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
