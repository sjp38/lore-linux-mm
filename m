Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 154836B01C7
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 10:41:36 -0400 (EDT)
Received: by pvg6 with SMTP id 6so737973pvg.14
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 07:41:35 -0700 (PDT)
Date: Wed, 16 Jun 2010 23:41:27 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/9] oom: don't try to kill oom_unkillable child
Message-ID: <20100616144127.GA9278@barrios-desktop>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 08:29:13PM +0900, KOSAKI Motohiro wrote:
> Now, badness() doesn't care neigher CPUSET nor mempolicy. Then
> if the victim child process have disjoint nodemask, __out_of_memory()
> can makes kernel hang eventually.
> 
> This patch fixes it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

This patch inclues two things. 

1. consider cpuset and mempolicy in oom_kill_process
2. Simplify mempolicy oom check with nodemask != NULL 
   in select_bad_process.

1) change behavior but 2) is just cleanup. 
It should have been in another patch to reivew easily. :)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
