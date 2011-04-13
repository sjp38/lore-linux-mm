Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE31900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:41:28 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p3DIfL1Q008142
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:41:22 -0700
Received: from pzk12 (pzk12.prod.google.com [10.243.19.140])
	by wpaz9.hot.corp.google.com with ESMTP id p3DIf3uc000558
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:41:20 -0700
Received: by pzk12 with SMTP id 12so1097046pzk.25
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:41:20 -0700 (PDT)
Date: Wed, 13 Apr 2011 11:41:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] remove boost_dying_task_prio()
In-Reply-To: <20110411143215.0074.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104131141040.5563@chino.kir.corp.google.com>
References: <20110411142949.006C.A69D9226@jp.fujitsu.com> <20110411143215.0074.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 11 Apr 2011, KOSAKI Motohiro wrote:

> This is a almost revert commit 93b43fa (oom: give the dying
> task a higher priority).
> 
> The commit dramatically improve oom killer logic when fork-bomb
> occur. But, I've found it has nasty corner case. Now cpu cgroup
> has strange default RT runtime. It's 0! That said, if a process
> under cpu cgroup promote RT scheduling class, the process never
> run at all.
> 
> Eventually, kernel may hang up when oom kill occur.
> I and Luis who original author agreed to disable this logic at
> once.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Luis Claudio R. Goncalves <lclaudio@uudg.org>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
