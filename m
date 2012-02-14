Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 4478A6B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 01:51:45 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6B7DE3EE0B5
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 15:51:43 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 52C0E45DE4D
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 15:51:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 38DB645DD78
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 15:51:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2958B1DB8038
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 15:51:43 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA87F1DB802C
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 15:51:42 +0900 (JST)
Date: Tue, 14 Feb 2012 15:50:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm] mm, oom: introduce independent oom killer ratelimit
 state
Message-Id: <20120214155001.75720c7a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1202131706320.30721@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1202131706320.30721@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Mon, 13 Feb 2012 17:07:31 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> printk_ratelimit() uses the global ratelimit state for all printks.  The
> oom killer should not be subjected to this state just because another
> subsystem or driver may be flooding the kernel log.
> 
> This patch introduces printk ratelimiting specifically for the oom
> killer.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
