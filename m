Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 99E966B0012
	for <linux-mm@kvack.org>; Mon,  9 May 2011 05:19:34 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 58D033EE0C5
	for <linux-mm@kvack.org>; Mon,  9 May 2011 18:19:31 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EDD145DE6B
	for <linux-mm@kvack.org>; Mon,  9 May 2011 18:19:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 230D045DE61
	for <linux-mm@kvack.org>; Mon,  9 May 2011 18:19:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 15EE41DB8044
	for <linux-mm@kvack.org>; Mon,  9 May 2011 18:19:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D051D1DB803E
	for <linux-mm@kvack.org>; Mon,  9 May 2011 18:19:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
In-Reply-To: <1491537913.283996.1304930866703.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
References: <20110509155612.1648.A69D9226@jp.fujitsu.com> <1491537913.283996.1304930866703.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-Id: <20110509182110.167F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon,  9 May 2011 18:19:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>

> > > I have tested this for the latest mainline kernel using the
> > > reproducer
> > > attached, the system just hung or deadlock after oom. The whole oom
> > > trace is here.
> > > http://people.redhat.com/qcai/oom.log
> > >
> > > Did I miss anything?
> > 
> > Can you please try commit 929bea7c714220fc76ce3f75bef9056477c28e74?
> As I have mentioned that I have tested the latest mainline which have
> already included that fix. Also, does this problem only for x86? The
> testing was done using x86_64. Not sure if that would be a problem.

No. I'm also using x86_64 and my machine completely works on current
latest linus tree. I confirmed it today.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
