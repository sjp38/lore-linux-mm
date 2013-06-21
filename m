Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na6sys010bmx033.postini.com [74.125.246.133])
	by kanga.kvack.org (Postfix) with SMTP id E3ECE6B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 20:31:09 -0400 (EDT)
Date: Fri, 21 Jun 2013 08:31:03 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH v4 2/6] mm/writeback: Don't check force_wait to handle
 bdi->work_list
Message-ID: <20130621003103.GC11033@localhost>
References: <1371599563-6424-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371599563-6424-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130620134615.GA10909@localhost>
 <20130620233724.GA26898@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130620233724.GA26898@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 21, 2013 at 07:37:25AM +0800, Wanpeng Li wrote:
> On Thu, Jun 20, 2013 at 09:46:15PM +0800, Fengguang Wu wrote:
> >>  fs/fs-writeback.c |   10 ++--------
> >>  1 files changed, 2 insertions(+), 8 deletions(-)
> >
> >The header file should be changed, too. Otherwise looks fine to me.
> >
> >include/linux/writeback.h:97:long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
> 
> Thanks for your review, Fengguang. ;-)
> 
> The line in header file has already been removed by commit(836f29bbb0:
> fs/fs-writeback.c: : make wb_do_writeback() as static) in -next tree
> since there is just one caller in fs/fs-writeback.c.

Ah OK. I was reading the upstream kernel.. However it still presents a
tricky situation (for Andrew Morton) that commit 836f29bbb0 MUST be
merged before your patch in the next merge window. Otherwise it will
lead to a range of build failure commits.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
