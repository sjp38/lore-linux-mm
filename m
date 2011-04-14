Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFF0900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 20:20:45 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6FBA83EE0AE
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:20:42 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 55B5945DE5B
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:20:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B32F45DE55
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:20:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 20BD7E38001
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:20:42 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB812E08002
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:20:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] forkbomb killer
In-Reply-To: <BANLkTi=pMapbVoUO6+7nUEg1bY4fb844-A@mail.gmail.com>
References: <20110329101234.54d5d45a.kamezawa.hiroyu@jp.fujitsu.com> <BANLkTi=pMapbVoUO6+7nUEg1bY4fb844-A@mail.gmail.com>
Message-Id: <20110414092033.0809.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 14 Apr 2011 09:20:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

Hi, Minchan, Kamezawa-san,

> >> So whenever user push sysrq, older tasks would be killed and at last,
> >> root forkbomb task would be killed.
> >>
> >
> > Maybe good for a single user system and it can send Sysrq.
> > But I myself not very excited with this new feature becasuse I need to
> > run to push Sysrq ....
> >
> > Please do as you like, I think the idea itself is interesting.
> > But I love some automatic ones. I do other jobs.
> 
> Okay. Thanks for the comment, Kame.
> 
> I hope Andrew or someone gives feedback forkbomb problem itself before
> diving into this.

May I ask current status of this thread? I'm unhappy if our kernel keep 
to have forkbomb weakness. ;)
Can we consider to take either or both idea?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
