Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 28B416006F7
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 10:04:04 -0400 (EDT)
Received: by pvg11 with SMTP id 11so414445pvg.14
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 07:04:02 -0700 (PDT)
Date: Wed, 30 Jun 2010 23:03:53 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 05/11] oom: /proc/<pid>/oom_score treat kernel thread
 honestly
Message-ID: <20100630140328.GC15644@barrios-desktop>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
 <20100630182922.AA56.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100630182922.AA56.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 30, 2010 at 06:30:19PM +0900, KOSAKI Motohiro wrote:
> If kernel thread are using use_mm(), badness() return positive value.
> This is not big issue because caller care it correctly. but there is
> one exception, /proc/<pid>/oom_score call badness() directly and
> don't care the task is regular process.
> 
> another example, /proc/1/oom_score return !0 value. but it's unkillable.
> This incorrectness makes confusing to admin a bit.

Hmm. If it is a really problem, Could we solve it in proc_oom_score itself?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
