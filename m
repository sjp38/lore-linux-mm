Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C6DCB6B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 04:20:55 -0400 (EDT)
Received: by pwi2 with SMTP id 2so5085345pwi.14
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 01:20:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
Date: Tue, 13 Apr 2010 16:20:53 +0800
Message-ID: <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

On 4/6/10, Bob Liu <lliubbo@gmail.com> wrote:
> In funtion migrate_pages(), if the dest node have no
> enough free pages,it will fallback to other nodes.
> Add GFP_THISNODE to avoid this, the same as what
> funtion new_page_node() do in migrate.c.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/mempolicy.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 08f40a2..fc5ddf5 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -842,7 +842,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>
>  static struct page *new_node_page(struct page *page, unsigned long node, int **x)
>  {
> -       return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
> +       return alloc_pages_exact_node(node,
> +                               GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
>  }
>

Hi, Minchan and Kame
     Would you please add ack or review to this thread. It's BUGFIX
and not change, so i don't resend one.

     About code clean, there should be some new CLEANUP patches or
just don't make any changes decided after we finish before
discussions.

Thanks!
-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
