Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 807916B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 07:37:28 -0500 (EST)
Date: Wed, 22 Feb 2012 13:37:25 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] MM: fix a typo of truncate_inode_pages_range
Message-ID: <20120222123725.GB28373@quack.suse.cz>
References: <1329793040-21406-1-git-send-email-liubo2009@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1329793040-21406-1-git-send-email-liubo2009@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Bo <liubo2009@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, trivial@kernel.org, linux-mm@kvack.org

On Tue 21-02-12 10:57:20, Liu Bo wrote:
> The typo of API truncate_inode_pages_range is not updated.
  It's better to add more specific recipients of patches. It's too easy to
overlook a patch in 400+ daily messages on LKML. In this particular case
using trivial tree for merging would be appropriate. Added CCs.

								Honza
> 
> Signed-off-by: Liu Bo <liubo2009@cn.fujitsu.com>
> ---
>  mm/truncate.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 632b15e..a188058 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -184,7 +184,7 @@ int invalidate_inode_page(struct page *page)
>  }
>  
>  /**
> - * truncate_inode_pages - truncate range of pages specified by start & end byte offsets
> + * truncate_inode_pages_range - truncate range of pages specified by start & end byte offsets
>   * @mapping: mapping to truncate
>   * @lstart: offset from which to truncate
>   * @lend: offset to which to truncate
> -- 
> 1.6.5.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
