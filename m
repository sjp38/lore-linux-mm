Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C08C36B0071
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 11:10:53 -0400 (EDT)
Received: by pvg6 with SMTP id 6so754071pvg.14
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 08:10:52 -0700 (PDT)
Date: Thu, 17 Jun 2010 00:10:45 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 5/9] oom: make oom_unkillable_task() helper function
Message-ID: <20100616151012.GE9278@barrios-desktop>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
 <20100616203247.72E3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100616203247.72E3.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 08:33:17PM +0900, KOSAKI Motohiro wrote:
> 
> Now, we have the same task check in three places. Unify it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

But please consider my previous comment.
If I am not wrong, we need change this patch, too.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
