Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id C3D086B0253
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 05:17:18 -0500 (EST)
Received: by wmww144 with SMTP id w144so50020370wmw.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 02:17:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rx8si3300685wjb.204.2015.12.02.02.17.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 02:17:17 -0800 (PST)
Date: Wed, 2 Dec 2015 11:17:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix kerneldoc on mem_cgroup_replace_page
Message-ID: <20151202101714.GD25284@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182152560.2481@eggly.anvils>
 <alpine.LSU.2.11.1512020130410.32078@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1512020130410.32078@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Wed 02-12-15 01:33:03, Hugh Dickins wrote:
> Whoops, I missed removing the kerneldoc comment of the lrucare arg
> removed from mem_cgroup_replace_page; but it's a good comment, keep it.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 4.4-rc3/mm/memcontrol.c	2015-11-15 21:06:56.505752425 -0800
> +++ linux/mm/memcontrol.c	2015-11-30 17:40:42.510193391 -0800
> @@ -5511,11 +5511,11 @@ void mem_cgroup_uncharge_list(struct lis
>   * mem_cgroup_replace_page - migrate a charge to another page
>   * @oldpage: currently charged page
>   * @newpage: page to transfer the charge to
> - * @lrucare: either or both pages might be on the LRU already
>   *
>   * Migrate the charge from @oldpage to @newpage.
>   *
>   * Both pages must be locked, @newpage->mapping must be set up.
> + * Either or both pages might be on the LRU already.
>   */
>  void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
>  {

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
