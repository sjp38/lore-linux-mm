Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 055D66B01F9
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 21:45:32 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 592BD3EE0BC
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 10:45:28 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FDD145DE94
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 10:45:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 26EFB45DE92
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 10:45:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 178191DB8052
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 10:45:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D6E391DB804A
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 10:45:27 +0900 (JST)
Message-ID: <4E014925.8030303@jp.fujitsu.com>
Date: Wed, 22 Jun 2011 10:45:09 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] oom: remove references to old badness() function
References: <alpine.DEB.2.00.1106211756580.4454@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1106211756580.4454@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

(2011/06/22 9:57), David Rientjes wrote:
> The badness() function in the oom killer was renamed to oom_badness() in
> a63d83f427fb ("oom: badness heuristic rewrite") since it is a globally
> exported function for clarity.
> 
> The prototype for the old function still existed in linux/oom.h, so
> remove it.  There are no existing users.
> 
> Also fixes documentation and comment references to badness() and adjusts
> them accordingly.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
