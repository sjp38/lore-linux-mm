Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8958D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 05:29:28 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8B2003EE0C1
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 18:29:24 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F63345DE6F
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 18:29:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 51BBB45DE4E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 18:29:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 42E47E08003
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 18:29:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E0941DB803A
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 18:29:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm, mem-hotplug: update pcp->stat_threshold when memory hotplug occur
In-Reply-To: <BANLkTi=fEejkrPdX27bFi1x+dHpOSGxQaQ@mail.gmail.com>
References: <20110411170134.035E.A69D9226@jp.fujitsu.com> <BANLkTi=fEejkrPdX27bFi1x+dHpOSGxQaQ@mail.gmail.com>
Message-Id: <20110412183010.B52A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 12 Apr 2011 18:29:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

Hi

> Hi, KOSAKI
> 
> On Mon, Apr 11, 2011 at 5:01 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Currently, cpu hotplug updates pcp->stat_threashold, but memory
> > hotplug doesn't. there is no reason.
> >
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Acked-by: Mel Gorman <mel@csn.ul.ie>
> > Acked-by: Christoph Lameter <cl@linux.com>
> 
> I can think it makes sense so I don't oppose the patch merging.
> But as you know I am very keen on the description.
> 
> What is the problem if hotplug doesn't do it?
> I means the patch solves what's problem?
> 
> Please write down fully for better description.
> Thanks.

No real world issue. I found the fault by code review.
No good stat_threshold might makes performance hurt.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
