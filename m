Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A64206B01AF
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:40 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1pc7F005965
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:38 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AE4645DE70
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2728245DE79
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D00B1DB803A
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B3C691DB8037
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/9] oom: don't try to kill oom_unkillable child
In-Reply-To: <20100616144127.GA9278@barrios-desktop>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com> <20100616144127.GA9278@barrios-desktop>
Message-Id: <20100617091325.FB4B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Jun 16, 2010 at 08:29:13PM +0900, KOSAKI Motohiro wrote:
> > Now, badness() doesn't care neigher CPUSET nor mempolicy. Then
> > if the victim child process have disjoint nodemask, __out_of_memory()
> > can makes kernel hang eventually.
> > 
> > This patch fixes it.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> This patch inclues two things. 
> 
> 1. consider cpuset and mempolicy in oom_kill_process
> 2. Simplify mempolicy oom check with nodemask != NULL 
>    in select_bad_process.
> 
> 1) change behavior but 2) is just cleanup. 
> It should have been in another patch to reivew easily. :)

Thank you. removed (2).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
