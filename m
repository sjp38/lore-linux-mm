Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 2117E6B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 19:49:23 -0400 (EDT)
Date: Thu, 25 Oct 2012 07:49:18 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH v2] Change the check for PageReadahead into an else-if
Message-ID: <20121024234918.GA7655@localhost>
References: <05ff4f71283e84be8ab1b312864168d89535239f.1351113536.git.rprabhu@wnohang.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <05ff4f71283e84be8ab1b312864168d89535239f.1351113536.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: raghu.prabhu13@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@gmail.com, zheng.z.yan@intel.com, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

On Thu, Oct 25, 2012 at 02:56:04AM +0530, raghu.prabhu13@gmail.com wrote:
> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> 
> >From 51daa88ebd8e0d437289f589af29d4b39379ea76, page_sync_readahead coalesces
> async readahead into its readahead window, so another checking for that again is
> not required.
> 
> Version 2: Fixed the incorrect indentation.
> 
> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
> ---
>  fs/btrfs/relocation.c | 4 +---
>  mm/filemap.c          | 3 +--
>  2 files changed, 2 insertions(+), 5 deletions(-)

Reviewed-by: Fengguang Wu <fengguang.wu@intel.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
