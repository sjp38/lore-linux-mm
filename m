Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 091436B0037
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 15:01:44 -0400 (EDT)
Received: by mail-yh0-f54.google.com with SMTP id f73so1697709yha.41
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 12:01:44 -0700 (PDT)
Date: Tue, 18 Jun 2013 12:01:39 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 3/6] mm/writeback: commit reason of
 WB_REASON_FORKER_THREAD mismatch name
Message-ID: <20130618190139.GG1596@htj.dyndns.org>
References: <1371555222-22678-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371555222-22678-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371555222-22678-3-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 18, 2013 at 07:33:39PM +0800, Wanpeng Li wrote:
> After commit 839a8e86("writeback: replace custom worker pool implementation
> with unbound workqueue"), there is no bdi forker thread any more. However,
> WB_REASON_FORKER_THREAD is still used due to it is somewhat userland visible
> and we won't be exposing exactly the same information with just a different
> name.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

> +/*
> + * There is no bdi forker thread any more and works are done by emergency
> + * worker, however, this is somewhat userland visible and we'll be exposing
> + * exactly the same information, so it has a mismatch name.
> + */
>  	WB_REASON_FORKER_THREAD,

But it'd be probably better to explicitly point to the TPs rather than
saying "somewhat" visible.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
