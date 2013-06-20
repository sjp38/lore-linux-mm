From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 2/6] mm/writeback: Don't check force_wait to handle
 bdi->work_list
Date: Fri, 21 Jun 2013 07:37:25 +0800
Message-ID: <49016.3730959923$1371771473@news.gmane.org>
References: <1371599563-6424-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371599563-6424-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130620134615.GA10909@localhost>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UpoQA-00009D-Q1
	for glkm-linux-mm-2@m.gmane.org; Fri, 21 Jun 2013 01:37:43 +0200
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 79E536B0034
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 19:37:40 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 21 Jun 2013 09:28:07 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 946D82CE8044
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 09:37:31 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5KNMbvM5701964
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 09:22:38 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5KNbT5T025131
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 09:37:30 +1000
Content-Disposition: inline
In-Reply-To: <20130620134615.GA10909@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 20, 2013 at 09:46:15PM +0800, Fengguang Wu wrote:
>>  fs/fs-writeback.c |   10 ++--------
>>  1 files changed, 2 insertions(+), 8 deletions(-)
>
>The header file should be changed, too. Otherwise looks fine to me.
>
>include/linux/writeback.h:97:long wb_do_writeback(struct bdi_writeback *wb, int force_wait);

Thanks for your review, Fengguang. ;-)

The line in header file has already been removed by commit(836f29bbb0:
fs/fs-writeback.c: : make wb_do_writeback() as static) in -next tree
since there is just one caller in fs/fs-writeback.c.

Regards,
Wanpeng Li 

>
>Thanks,
>Fengguang
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
