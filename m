Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8A62A6B01B9
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 10:42:49 -0400 (EDT)
Received: by pwi9 with SMTP id 9so849204pwi.14
        for <linux-mm@kvack.org>; Thu, 01 Jul 2010 07:42:48 -0700 (PDT)
Date: Thu, 1 Jul 2010 23:36:08 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 05/11] oom: /proc/<pid>/oom_score treat kernel thread
 honestly
Message-ID: <20100701143608.GB16383@barrios-desktop>
References: <20100630182922.AA56.A69D9226@jp.fujitsu.com>
 <20100630140328.GC15644@barrios-desktop>
 <20100701085309.DA16.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100701085309.DA16.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 01, 2010 at 09:07:02AM +0900, KOSAKI Motohiro wrote:
> > On Wed, Jun 30, 2010 at 06:30:19PM +0900, KOSAKI Motohiro wrote:
> > > If kernel thread are using use_mm(), badness() return positive value.
> > > This is not big issue because caller care it correctly. but there is
> > > one exception, /proc/<pid>/oom_score call badness() directly and
> > > don't care the task is regular process.
> > > 
> > > another example, /proc/1/oom_score return !0 value. but it's unkillable.
> > > This incorrectness makes confusing to admin a bit.
> > 
> > Hmm. If it is a really problem, Could we solve it in proc_oom_score itself?
> 
> probably, no good idea. For maintainance view, all oom related code should
> be gathered in oom_kill.c.
> If you dislike to add messy into badness(), I hope to make badness_for_oom_score()

I am looking forward to seeing your next series.
Thanks, Kosaki. 

P.S) 
I think if the number of patch series is the bigger than #10, 
It would be better to include or point url of all-at-once patch 
in patch series.

In case of your patch, post patches changes pre patches
It could make hard review unless the reviewer merge patches into tree to
see the final figure. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
