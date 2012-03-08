Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id B8CD46B0092
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 00:43:12 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3F7883EE0C1
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:43:11 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 283B245DE4F
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:43:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F74145DE4D
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:43:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 001CE1DB8037
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:43:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AFC881DB802F
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:43:10 +0900 (JST)
Date: Thu, 8 Mar 2012 14:41:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/2] mm, counters: fold __sync_task_rss_stat into
 sync_mm_rss
Message-Id: <20120308144138.d8ace9d3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1203061920370.21806@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061919260.21806@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1203061920370.21806@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 6 Mar 2012 19:21:42 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> There's no difference between sync_mm_rss() and __sync_task_rss_stat(),
> so fold the latter into the former.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
