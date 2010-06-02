Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9AC6E6B01AF
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 11:37:52 -0400 (EDT)
Received: by pzk6 with SMTP id 6so1180352pzk.1
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 08:37:51 -0700 (PDT)
Date: Thu, 3 Jun 2010 00:32:01 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/5] oom: select_bad_process: check PF_KTHREAD instead
 of !mm to skip kthreads
Message-ID: <20100602153201.GB5326@barrios-desktop>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100531182526.1843.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, May 31, 2010 at 06:33:06PM +0900, KOSAKI Motohiro wrote:
> From: Oleg Nesterov <oleg@redhat.com>
> Subject: oom: select_bad_process: check PF_KTHREAD instead of !mm to skip kthreads
> 
> select_bad_process() thinks a kernel thread can't have ->mm != NULL, this
> is not true due to use_mm().
> 
> Change the code to check PF_KTHREAD.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
