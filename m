Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3B38D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:21:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 76FE43EE0C0
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:21:40 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 57F6F45DE5F
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:21:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BC7A45DE59
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:21:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B3281DB8040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:21:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E37C7E38003
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:21:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Stack trace dedup
In-Reply-To: <1301419696-2045-1-git-send-email-yinghan@google.com>
References: <1301419696-2045-1-git-send-email-yinghan@google.com>
Message-Id: <20110330102205.E925.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Mar 2011 10:21:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

> This doesn't build.
> ---
>  arch/x86/Kconfig                  |    3 +
>  arch/x86/include/asm/stacktrace.h |    2 +-
>  arch/x86/kernel/dumpstack.c       |    5 +-
>  arch/x86/kernel/dumpstack_64.c    |   10 +++-
>  arch/x86/kernel/stacktrace.c      |  108 +++++++++++++++++++++++++++++++++++++
>  include/linux/sched.h             |   10 +++-
>  init/main.c                       |    1 +
>  kernel/sched.c                    |   25 ++++++++-
>  8 files changed, 154 insertions(+), 10 deletions(-)

This is slightly reticence changelog. Can you please explain a purpose
and benefit?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
