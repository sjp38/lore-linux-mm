Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 449E36B031B
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 06:12:58 -0400 (EDT)
Date: Fri, 20 Aug 2010 18:12:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in
 /proc/vmstat
Message-ID: <20100820101251.GD8440@localhost>
References: <1282296689-25618-1-git-send-email-mrubin@google.com>
 <1282296689-25618-5-git-send-email-mrubin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282296689-25618-5-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 05:31:29PM +0800, Michael Rubin wrote:
> The kernel already exposes the user desired thresholds in /proc/sys/vm
> with dirty_background_ratio and background_ratio. But the kernel may
> alter the number requested without giving the user any indication that
> is the case.
> 
> Knowing the actual ratios the kernel is honoring can help app developers
> understand how their buffered IO will be sent to the disk.
> 
> 	$ grep threshold /proc/vmstat
> 	nr_dirty_threshold 409111
> 	nr_dirty_background_threshold 818223
> 
> Signed-off-by: Michael Rubin <mrubin@google.com>
> ---
>  include/linux/mmzone.h |    3 +++
>  mm/vmstat.c            |    5 +++++
>  2 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index fe4e6dd..c2243d0 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -106,6 +106,9 @@ enum zone_stat_item {
>  	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
>  	NR_FILE_PAGES_DIRTIED,	/* number of times pages get dirtied */
>  	NR_PAGES_ENTERED_WRITEBACK, /* number of times pages enter writeback */
> +	NR_DIRTY_THRESHOLD,	/* writeback threshold */
> +	NR_DIRTY_BG_THRESHOLD,	/* bg writeback threshold */

This may cost cacheline.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
