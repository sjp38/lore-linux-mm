Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BC7AE8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 00:50:17 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6D41E3EE0C5
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:50:14 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 547C945DE5A
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:50:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D2BA45DE56
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:50:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D758E08002
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:50:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E30981DB8049
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:50:13 +0900 (JST)
Date: Wed, 9 Mar 2011 14:43:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in
 all_unreclaimable()
Message-Id: <20110309144353.387d946e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110309143704.194e8ee1.kamezawa.hiroyu@jp.fujitsu.com>
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>
	<20110305152056.GA1918@barrios-desktop>
	<4D72580D.4000208@gmail.com>
	<20110305155316.GB1918@barrios-desktop>
	<4D7267B6.6020406@gmail.com>
	<20110305170759.GC1918@barrios-desktop>
	<20110307135831.9e0d7eaa.akpm@linux-foundation.org>
	<AANLkTinDhorLusBju=Gn3bh1VsH1jrv0qixbU3SGWiqa@mail.gmail.com>
	<20110309143704.194e8ee1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrew Vagin <avagin@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 9 Mar 2011 14:37:04 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 8 Mar 2011 08:45:51 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> Hmm, should I support a sacrifice feature 'some signal(SIGINT?) will be sent by
> the kernel when it detects system memory is in short' in cgroup ?
> (For example, if full LRU scan is done in a zone, notifier
>  works and SIGINT will be sent.)
> 

Sorry, this sounds like  "mem_notify" ;), Kosaki-san's old work.

I think functionality for "mem_notify" will have no obstacle opinion but
implementation detail is a problem....Shouldn't we try it again ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
