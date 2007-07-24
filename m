Date: Mon, 23 Jul 2007 17:20:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] fix hugetlb page allocation leak
Message-Id: <20070723172019.376ca936.akpm@linux-foundation.org>
In-Reply-To: <b040c32a0707231711p3ea6b213wff15e7a58ee48f61@mail.gmail.com>
References: <b040c32a0707231711p3ea6b213wff15e7a58ee48f61@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2007 17:11:49 -0700
"Ken Chen" <kenchen@google.com> wrote:

> dequeue_huge_page() has a serious memory leak upon hugetlb page
> allocation.  The for loop continues on allocating hugetlb pages out of
> all allowable zone, where this function is supposedly only dequeue one
> and only one pages.
> 
> Fixed it by breaking out of the for loop once a hugetlb page is found.
> 
> 
> Signed-off-by: Ken Chen <kenchen@google.com>
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index f127940..d7ca59d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -84,6 +84,7 @@ static struct page *dequeue_huge_page(st
>  			list_del(&page->lru);
>  			free_huge_pages--;
>  			free_huge_pages_node[nid]--;
> +			break;
>  		}
>  	}
>  	return page;

that would be due to some idiot merging untested stuff.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
