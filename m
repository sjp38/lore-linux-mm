Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id AA8C19000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 00:52:32 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A67093EE0C1
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:52:28 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B55645DE81
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:52:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FA2345DE7F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:52:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 604211DB803A
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:52:28 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 288DD1DB803F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:52:28 +0900 (JST)
Date: Wed, 28 Sep 2011 13:51:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm: disable user interface to manually rescue
 unevictable pages
Message-Id: <20110928135138.5113bc30.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110927072714.GA1997@redhat.com>
References: <1316948380-1879-1-git-send-email-consul.kautuk@gmail.com>
	<20110926112944.GC14333@redhat.com>
	<20110926161136.b4508ecb.akpm@google.com>
	<20110927072714.GA1997@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@google.com>, Kautuk Consul <consul.kautuk@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 27 Sep 2011 09:27:14 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> At one point, anonymous pages were supposed to go on the unevictable
> list when no swap space was configured, and the idea was to manually
> rescue those pages after adding swap and making them evictable again.
> But nowadays, swap-backed pages on the anon LRU list are not scanned
> without available swap space anyway, so there is no point in moving
> them to a separate list anymore.
> 
> The manual rescue could also be used in case pages were stranded on
> the unevictable list due to race conditions.  But the code has been
> around for a while now and newly discovered bugs should be properly
> reported and dealt with instead of relying on such a manual fixup.
> 
> In addition to the lack of a usecase, the sysfs interface to rescue
> pages from a specific NUMA node has been broken since its
> introduction, so it's unlikely that anybody ever relied on that.
> 
> This patch removes the functionality behind the sysctl and the
> node-interface and emits a one-time warning when somebody tries to
> access either of them.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Reported-by: Kautuk Consul <consul.kautuk@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
