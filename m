Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id ED9546B00D2
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 23:24:42 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7422D3EE0BB
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:24:41 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 59A0A45DE53
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:24:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D8FB45DE50
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:24:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F2D0E18004
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:24:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D6835E08002
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:24:40 +0900 (JST)
Message-ID: <4FE92AF9.4050309@jp.fujitsu.com>
Date: Tue, 26 Jun 2012 12:22:33 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch 2/3] mm, oom: introduce helper function to process
 threads during scan
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206251846450.24838@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206251846450.24838@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

(2012/06/26 10:47), David Rientjes wrote:
> This patch introduces a helper function to process each thread during the
> iteration over the tasklist.  A new return type, enum oom_scan_t, is
> defined to determine the future behavior of the iteration:
>
>   - OOM_SCAN_OK: continue scanning the thread and find its badness,
>
>   - OOM_SCAN_CONTINUE: do not consider this thread for oom kill, it's
>     ineligible,
>
>   - OOM_SCAN_ABORT: abort the iteration and return, or
>
>   - OOM_SCAN_SELECT: always select this thread with the highest badness
>     possible.
>
> There is no functional change with this patch.  This new helper function
> will be used in the next patch in the memory controller.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

I like this.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
