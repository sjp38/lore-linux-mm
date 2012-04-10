Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 564A06B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 20:37:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 82B1A3EE0B6
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:37:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E52045DE5E
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:37:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 45F3E45DE5A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:37:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 29E1FE38007
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:37:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CEC42E38003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:37:14 +0900 (JST)
Message-ID: <4F838051.50101@jp.fujitsu.com>
Date: Tue, 10 Apr 2012 09:35:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: sync rss-counters at the end of exit_mm()
References: <20120409200336.8368.63793.stgit@zurg>
In-Reply-To: <20120409200336.8368.63793.stgit@zurg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Markus Trippelsdorf <markus@trippelsdorf.de>

(2012/04/10 5:03), Konstantin Khlebnikov wrote:

> On task's exit do_exit() calls sync_mm_rss() but this is not enough,
> there can be page-faults after this point, for example exit_mm() ->
> mm_release() -> put_user() (for processing tsk->clear_child_tid).
> Thus there may be some rss-counters delta in current->rss_stat.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Does this fix recent issue reported ?

 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
