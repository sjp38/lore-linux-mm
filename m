Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 83C646B0036
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 05:31:50 -0400 (EDT)
Date: Fri, 14 Jun 2013 17:31:21 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
Subject: Re: [PATCH 1/8] mm/writeback: fix wb_do_writeback exported unsafely
Message-ID: <20130614093121.GB28555@hli22-desktop>
References: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On Fri, Jun 14, 2013 at 03:30:34PM +0800, Wanpeng Li wrote:
> There is just one caller in fs-writeback.c call wb_do_writeback and
> current codes unnecessary export it in header file, this patch fix
> it by changing wb_do_writeback to static function.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Hi Wanpeng,

A simliar patch has been merged in -next tree with commit#: 836f29bbb0f7a08dbdf1ed3ee704ef8aea81e56f

BTW, actually this should have nothing to do with safety, just unnecessary to export it globally.
> ---
>  fs/fs-writeback.c         | 2 +-
>  include/linux/writeback.h | 1 -
>  2 files changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 3be5718..f892dec 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -959,7 +959,7 @@ static long wb_check_old_data_flush(struct bdi_writeback *wb)
>  /*
>   * Retrieve work items and do the writeback they describe
>   */
> -long wb_do_writeback(struct bdi_writeback *wb, int force_wait)
> +static long wb_do_writeback(struct bdi_writeback *wb, int force_wait)
>  {
>  	struct backing_dev_info *bdi = wb->bdi;
>  	struct wb_writeback_work *work;
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index 579a500..e27468e 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -94,7 +94,6 @@ int try_to_writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
>  void sync_inodes_sb(struct super_block *);
>  long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
>  				enum wb_reason reason);
> -long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
>  void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
>  void inode_wait_for_writeback(struct inode *inode);
>  
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
