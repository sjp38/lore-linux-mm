Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 936CC6B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 02:47:29 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n756lXJ3002350
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 5 Aug 2009 15:47:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6174F45DE6F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:47:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AE1E45DE4D
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:47:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 094461DB8041
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:47:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A36C71DB803F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:47:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] oom: move oom_adj to signal_struct
In-Reply-To: <20090805152956.faf52a5a.minchan.kim@barrios-desktop>
References: <20090805150017.5BB9.A69D9226@jp.fujitsu.com> <20090805152956.faf52a5a.minchan.kim@barrios-desktop>
Message-Id: <20090805153157.5BBF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  5 Aug 2009 15:47:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > > What do you think about this approach ?
> > 
> > I can ack this. but please re-initialize oom_scale_down at fork and
> > exec time.
> > currently oom_scale_down makes too big affect.
> 
> 
> Thanks for carefult review. 
> In fact, I didn't care of it 
> since it just is RFC for making sure my idea. :)

ok, I see.

> > and, May I ask which you hate my approach? 
> 
> Not at all. I never hate your approach. 
> This problem resulted form David's original patch.
> I thought if we will fix live lock with different approach, we can remove much pain.

I also think your approach is enough acceptable.

ok, Let's wait one night and to hear other developer's opinion.
We can choice more lkml preferred approach :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
