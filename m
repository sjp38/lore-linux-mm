Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 42CD08D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 05:37:51 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6E12A3EE0AE
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 19:37:47 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 542E945DE52
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 19:37:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3954245DE4F
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 19:37:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 28EBF1DB803E
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 19:37:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E2C971DB8037
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 19:37:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: skip zombie in OOM-killer
In-Reply-To: <1299286307-4386-1-git-send-email-avagin@openvz.org>
References: <1299286307-4386-1-git-send-email-avagin@openvz.org>
Message-Id: <20110306193519.49DD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  6 Mar 2011 19:37:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Vagin <avagin@openvz.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> When we check that task has flag TIF_MEMDIE, we forgot check that
> it has mm. A task may be zombie and a parent may wait a memor.
> 
> v2: Check that task doesn't have mm one time and skip it immediately
> 
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

This seems incorrect. Do you have a reprodusable testcasae?
Your patch only care thread group leader state, but current code
care all thread in the process. Please look at oom_badness() and 
find_lock_task_mm(). 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
