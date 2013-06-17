Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 461D26B0039
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 04:30:33 -0400 (EDT)
Date: Mon, 17 Jun 2013 10:30:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 3/7] mm/writeback: commit reason of
 WB_REASON_FORKER_THREAD mismatch name
Message-ID: <20130617083030.GE19194@dhcp22.suse.cz>
References: <1371345290-19588-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371345290-19588-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371345290-19588-3-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 16-06-13 09:14:46, Wanpeng Li wrote:
> After commit 839a8e86("writeback: replace custom worker pool implementation
> with unbound workqueue"), there is no bdi forker thread any more. However,
> WB_REASON_FORKER_THREAD is still used due to it is somewhat userland visible 

What exactly "somewhat userland visible" means?
Is this about trace events?

> and we won't be exposing exactly the same information with just a different 
> name. 
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  include/linux/writeback.h | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index 8b5cec4..cf077a7 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -47,6 +47,11 @@ enum wb_reason {
>  	WB_REASON_LAPTOP_TIMER,
>  	WB_REASON_FREE_MORE_MEM,
>  	WB_REASON_FS_FREE_SPACE,
> +/*
> + * There is no bdi forker thread any more and works are done by emergency
> + * worker, however, this is somewhat userland visible and we'll be exposing
> + * exactly the same information, so it has a mismatch name.
> + */
>  	WB_REASON_FORKER_THREAD,
>  
>  	WB_REASON_MAX,
> -- 
> 1.8.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
