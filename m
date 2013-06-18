Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id A04B36B0034
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 15:00:34 -0400 (EDT)
Received: by mail-ye0-f170.google.com with SMTP id q3so1494513yen.15
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 12:00:33 -0700 (PDT)
Date: Tue, 18 Jun 2013 12:00:27 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/6] mm/writeback: Don't check force_wait to handle
 bdi->work_list
Message-ID: <20130618190027.GF1596@htj.dyndns.org>
References: <1371555222-22678-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371555222-22678-2-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371555222-22678-2-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 18, 2013 at 07:33:38PM +0800, Wanpeng Li wrote:
> After commit 839a8e86("writeback: replace custom worker pool implementation
> with unbound workqueue"), bdi_writeback_workfn runs off bdi_writeback->dwork,
> on each execution, it processes bdi->work_list and reschedules if there are
> more things to do instead of flush any work that race with us existing. It is
> unecessary to check force_wait in wb_do_writeback since it is always 0 after
> the mentioned commit. This patch remove the force_wait in wb_do_writeback.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
