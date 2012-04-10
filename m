Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id D0DAE6B007E
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 01:43:18 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so5209573bkw.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 22:43:17 -0700 (PDT)
Message-ID: <4F83C870.2090100@openvz.org>
Date: Tue, 10 Apr 2012 09:43:12 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: sync rss-counters at the end of exit_mm()
References: <20120409200336.8368.63793.stgit@zurg> <4F838051.50101@jp.fujitsu.com>
In-Reply-To: <4F838051.50101@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Markus Trippelsdorf <markus@trippelsdorf.de>

KAMEZAWA Hiroyuki wrote:
> (2012/04/10 5:03), Konstantin Khlebnikov wrote:
>
>> On task's exit do_exit() calls sync_mm_rss() but this is not enough,
>> there can be page-faults after this point, for example exit_mm() ->
>> mm_release() ->  put_user() (for processing tsk->clear_child_tid).
>> Thus there may be some rss-counters delta in current->rss_stat.

I had to mention it in comment:

This should fix warnings:
BUG: Bad rss-counter state mm:ffff88020813c380 idx:1 val:-1
BUG: Bad rss-counter state mm:ffff88020813c380 idx:2 val:1

>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>> Reported-by: Markus Trippelsdorf<markus@trippelsdorf.de>
>> Cc: Hugh Dickins<hughd@google.com>
>> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> Does this fix recent issue reported ?
>

I hope so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
