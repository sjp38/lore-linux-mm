Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 1FCA06B003A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 09:26:10 -0400 (EDT)
Date: Tue, 9 Apr 2013 15:26:07 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 06/18] ocfs2: use ->invalidatepage() length argument
Message-ID: <20130409132607.GD13672@quack.suse.cz>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
 <1365498867-27782-7-git-send-email-lczerner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365498867-27782-7-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Joel Becker <jlbec@evilplan.org>

On Tue 09-04-13 11:14:15, Lukas Czerner wrote:
> ->invalidatepage() aop now accepts range to invalidate so we can make
> use of it in ocfs2_invalidatepage().
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> Cc: Joel Becker <jlbec@evilplan.org>
> ---
>  fs/ocfs2/aops.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
> index 7c47755..79736a2 100644
> --- a/fs/ocfs2/aops.c
> +++ b/fs/ocfs2/aops.c
> @@ -608,8 +608,7 @@ static void ocfs2_invalidatepage(struct page *page, unsigned int offset,
>  {
>  	journal_t *journal = OCFS2_SB(page->mapping->host->i_sb)->journal->j_journal;
>  
> -	jbd2_journal_invalidatepage(journal, page, offset,
> -				    PAGE_CACHE_SIZE - offset);
> +	jbd2_journal_invalidatepage(journal, page, offset, length);
>  }
>  
>  static int ocfs2_releasepage(struct page *page, gfp_t wait)
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
