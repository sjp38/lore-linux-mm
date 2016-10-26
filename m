Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9CC06B0285
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:07:48 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b80so12020698wme.5
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:07:48 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id f8si1351865wjn.53.2016.10.26.02.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 02:07:47 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id m83so3072355wmc.6
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:07:47 -0700 (PDT)
Date: Wed, 26 Oct 2016 11:07:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fixup get_user_pages* comments
Message-ID: <20161026090746.GB18382@dhcp22.suse.cz>
References: <20161025233435.5338-1-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025233435.5338-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed 26-10-16 00:34:35, Lorenzo Stoakes wrote:
> In the previous round of get_user_pages* changes comments attached to
> __get_user_pages_unlocked() and get_user_pages_unlocked() were rendered
> incorrect, this patch corrects them.
> 
> In addition the get_user_pages_unlocked() comment seems to have already been
> outdated as it referred to tsk, mm parameters which were removed in c12d2da5
> ("mm/gup: Remove the macro overload API migration helpers from the get_user*()
> APIs"), this patch fixes this also.
> 
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/gup.c | 16 ++++++----------
>  1 file changed, 6 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index ec4f827..e6147f1 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -857,14 +857,12 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
>  EXPORT_SYMBOL(get_user_pages_locked);
>  
>  /*
> - * Same as get_user_pages_unlocked(...., FOLL_TOUCH) but it allows to
> - * pass additional gup_flags as last parameter (like FOLL_HWPOISON).
> + * Same as get_user_pages_unlocked(...., FOLL_TOUCH) but it allows for
> + * tsk, mm to be specified.
>   *
>   * NOTE: here FOLL_TOUCH is not set implicitly and must be set by the
> - * caller if required (just like with __get_user_pages). "FOLL_GET",
> - * "FOLL_WRITE" and "FOLL_FORCE" are set implicitly as needed
> - * according to the parameters "pages", "write", "force"
> - * respectively.
> + * caller if required (just like with __get_user_pages). "FOLL_GET"
> + * is set implicitly if "pages" is non-NULL.
>   */
>  __always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
>  					       unsigned long start, unsigned long nr_pages,
> @@ -894,10 +892,8 @@ EXPORT_SYMBOL(__get_user_pages_unlocked);
>   *      get_user_pages_unlocked(tsk, mm, ..., pages);
>   *
>   * It is functionally equivalent to get_user_pages_fast so
> - * get_user_pages_fast should be used instead, if the two parameters
> - * "tsk" and "mm" are respectively equal to current and current->mm,
> - * or if "force" shall be set to 1 (get_user_pages_fast misses the
> - * "force" parameter).
> + * get_user_pages_fast should be used instead if specific gup_flags
> + * (e.g. FOLL_FORCE) are not required.
>   */
>  long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  			     struct page **pages, unsigned int gup_flags)
> -- 
> 2.10.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
