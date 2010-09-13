Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 37C026B00D2
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 23:15:31 -0400 (EDT)
Date: Mon, 13 Sep 2010 11:15:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] writeback: Reporting dirty thresholds in
 /proc/vmstat
Message-ID: <20100913031524.GD7697@localhost>
References: <1284323440-23205-1-git-send-email-mrubin@google.com>
 <1284323440-23205-6-git-send-email-mrubin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284323440-23205-6-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 04:30:40AM +0800, Michael Rubin wrote:
> The kernel already exposes the user desired thresholds in /proc/sys/vm
> with dirty_background_ratio and background_ratio. But the kernel may
> alter the number requested without giving the user any indication that
> is the case.
> 
> Knowing the actual ratios the kernel is honoring can help app developers
> understand how their buffered IO will be sent to the disk.
> 
>         $ grep threshold /proc/vmstat
>         nr_dirty_threshold 409111
>         nr_dirty_background_threshold 818223
> 
> Signed-off-by: Michael Rubin <mrubin@google.com>
> ---
>  include/linux/mmzone.h |    2 ++
>  mm/vmstat.c            |    4 ++++
>  2 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d0d7454..1e87936 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -106,6 +106,8 @@ enum zone_stat_item {
>  	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
>  	NR_FILE_DIRTIED,	/* accumulated dirty pages */
>  	NR_WRITTEN,		/* accumulated written pages */
> +	NR_DIRTY_THRESHOLD,	/* writeback threshold */

s/writeback/dirty throttling/

> +	NR_DIRTY_BG_THRESHOLD,	/* bg writeback threshold */

I have no idea about this interface change. No ACK or NAK.

But technical wise, the above two enum items should better be removed
to avoid possibly eating one more cache line. The two items can be
printed by explicit code.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
