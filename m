Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 368D86006F7
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 09:55:13 -0400 (EDT)
Received: by pzk33 with SMTP id 33so25998pzk.14
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 06:55:11 -0700 (PDT)
Date: Wed, 30 Jun 2010 22:55:03 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 02/11] oom: oom_kill_process() doesn't select kthread
 child
Message-ID: <20100630135503.GA15644@barrios-desktop>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
 <20100630182715.AA4B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100630182715.AA4B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 30, 2010 at 06:27:52PM +0900, KOSAKI Motohiro wrote:
> Now, select_bad_process() have PF_KTHREAD check, but oom_kill_process
> doesn't. It mean oom_kill_process() may choose wrong task, especially,
> when the child are using use_mm().

Is it possible child is kthread even though parent isn't kthread?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
