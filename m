Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 4FAED6B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 13:57:17 -0400 (EDT)
Received: by mail-gh0-f179.google.com with SMTP id f16so233492ghb.38
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 10:57:16 -0700 (PDT)
Date: Fri, 14 Jun 2013 10:57:10 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/8] mm/writeback: rename WB_REASON_FORKER_THREAD to
 WB_REASON_WORKER_THREAD
Message-ID: <20130614175710.GB6593@mtj.dyndns.org>
References: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371195041-26654-4-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371195041-26654-4-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 14, 2013 at 03:30:37PM +0800, Wanpeng Li wrote:
> After commit 839a8e86("writeback: replace custom worker pool implementation
> with unbound workqueue"), there is no bdi forker thread any more. This patch
> rename WB_REASON_FORKER_THREAD to WB_REASON_WORKER_THREAD since works are
> done by emergency worker.

This is somewhat userland visible and we'll be exposing exactly the
same information with just a different name.  While the string doesn't
match the current implementation exactly, I don't think we need to
change it.  Maybe add a comment there saying why it has a mismatching
name is enough?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
