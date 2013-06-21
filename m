Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 2AF7D6B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 20:49:23 -0400 (EDT)
Date: Fri, 21 Jun 2013 08:49:18 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH v5 3/6] commit reason of WB_REASON_FORKER_THREAD mismatch
 name
Message-ID: <20130621004918.GF11033@localhost>
References: <1371774534-4139-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371774534-4139-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371774534-4139-3-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -47,6 +47,12 @@ enum wb_reason {
>  	WB_REASON_LAPTOP_TIMER,
>  	WB_REASON_FREE_MORE_MEM,
>  	WB_REASON_FS_FREE_SPACE,
> +	/*
> +	 * There is no bdi forker thread any more and works are done
> +	 * by emergency worker, however, this is somewhat userland
> +	 * visible and we'll be exposing exactly the same information,
> +	 * so it has a mismatch name.
> +	 */
>  	WB_REASON_FORKER_THREAD,

Hmm, that reverted to the old "somewhat userland visible"?
And it seems hard to do a brief introduction of the situation..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
