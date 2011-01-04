Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9CCCF6B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 05:13:57 -0500 (EST)
Date: Tue, 4 Jan 2011 11:13:51 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] writeback: fix typo of global_dirty_limits comment
In-Reply-To: <1294072608-3172-1-git-send-email-minchan.kim@gmail.com>
Message-ID: <alpine.LNX.2.00.1101041113440.26685@pobox.suse.cz>
References: <1294072608-3172-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 4 Jan 2011, Minchan Kim wrote:

> Change runtime with real-time
> 
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/page-writeback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index c340536..98b79e2 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -384,7 +384,7 @@ unsigned long determine_dirtyable_memory(void)
>   * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
>   * - vm.dirty_ratio             or  vm.dirty_bytes
>   * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
> - * runtime tasks.
> + * real-time tasks.
>   */
>  void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
>  {

Applied, thank you.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
