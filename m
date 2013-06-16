Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 8D5856B0034
	for <linux-mm@kvack.org>; Sat, 15 Jun 2013 20:10:47 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 16 Jun 2013 05:33:10 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id A433C1258052
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 05:39:36 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5G0AZQg26083338
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 05:40:36 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5G0AdG9005868
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 10:10:39 +1000
Date: Sun, 16 Jun 2013 08:10:37 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/8] mm/writeback: rename WB_REASON_FORKER_THREAD to
 WB_REASON_WORKER_THREAD
Message-ID: <20130616001037.GA17121@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371195041-26654-4-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130614175710.GB6593@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130614175710.GB6593@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 14, 2013 at 10:57:10AM -0700, Tejun Heo wrote:
>On Fri, Jun 14, 2013 at 03:30:37PM +0800, Wanpeng Li wrote:
>> After commit 839a8e86("writeback: replace custom worker pool implementation
>> with unbound workqueue"), there is no bdi forker thread any more. This patch
>> rename WB_REASON_FORKER_THREAD to WB_REASON_WORKER_THREAD since works are
>> done by emergency worker.
>
>This is somewhat userland visible and we'll be exposing exactly the
>same information with just a different name.  While the string doesn't
>match the current implementation exactly, I don't think we need to
>change it.  Maybe add a comment there saying why it has a mismatching
>name is enough?
>

Good point, I will update them in next version, thanks for your review.
;-)

Regards,
Wanpeng Li 

>Thanks.
>
>-- 
>tejun
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
