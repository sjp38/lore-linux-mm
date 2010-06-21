Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EDE6F6B01AD
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 16:10:00 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o5LK9wBp020631
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:09:58 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by wpaz1.hot.corp.google.com with ESMTP id o5LK9u5F007619
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:09:57 -0700
Received: by pwj9 with SMTP id 9so1493351pwj.30
        for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:09:56 -0700 (PDT)
Date: Mon, 21 Jun 2010 13:09:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/9] oom: cleanup has_intersects_mems_allowed()
In-Reply-To: <20100617134601.FBA7.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006211305590.8367@chino.kir.corp.google.com>
References: <20100617104719.FB8C.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006162119540.14101@chino.kir.corp.google.com> <20100617134601.FBA7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jun 2010, KOSAKI Motohiro wrote:

> > I disagree that the renaming of the variables is necessary, please simply 
> > change the while (tsk != start) to use while_each_thread(tsk, start);
> 
> This is common naming rule of while_each_thread(). please grep.
> 

I disagree, there's no sense in substituting variable names like "tsk" for 
`p' and removing a very clear and obvious "start" task: it doesn't improve 
code readability.

I'm in favor of changing the while (tsk != start) to 
while_each_thread(tsk, start) which is very trivial to understand and much 
more readable than while_each_thread(p, tsk).  With the latter, it's not 
clear whether `p' or "tsk" is the iterator and which is the constant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
