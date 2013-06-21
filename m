From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 2/6] mm/writeback: Don't check force_wait to handle
 bdi->work_list
Date: Fri, 21 Jun 2013 09:26:14 +0800
Message-ID: <13969.0869757489$1371777994@news.gmane.org>
References: <1371774534-4139-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371774534-4139-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130621003330.GD11033@localhost>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Upq7L-00082r-Ug
	for glkm-linux-mm-2@m.gmane.org; Fri, 21 Jun 2013 03:26:24 +0200
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 343126B0068
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 21:26:22 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 21 Jun 2013 22:22:42 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C1CF12BB0044
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 11:26:16 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5L1BNeT7471602
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 11:11:23 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5L1QFFN026676
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 11:26:16 +1000
Content-Disposition: inline
In-Reply-To: <20130621003330.GD11033@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 21, 2013 at 08:33:30AM +0800, Fengguang Wu wrote:
>Reviewed-by: Fengguang Wu <fengguang.wu@intel.com>
>
>Andrew: this patch must be ordered _after_ "fs/fs-writeback.c: make
>wb_do_writeback() as static" to avoid build errors.
>

I will fold this as note in v7, thanks for pointing out. ;-)

Regards,
Wanpeng Li 

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
