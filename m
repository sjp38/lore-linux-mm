Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 1AF456B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 20:49:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 40F063EE0BD
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 09:49:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 267FA45DE53
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 09:49:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C27445DE4E
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 09:49:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EEA0EE08001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 09:49:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 90FB81DB803E
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 09:49:32 +0900 (JST)
Message-ID: <50494473.8030008@jp.fujitsu.com>
Date: Fri, 07 Sep 2012 09:48:51 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/4] memory-hotplug: fix pages missed by race rather
 than failng
References: <1346978372-17903-1-git-send-email-minchan@kernel.org> <1346978372-17903-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1346978372-17903-5-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

(2012/09/07 9:39), Minchan Kim wrote:
> If race between allocation and isolation in memory-hotplug offline
> happens, some pages could be in MIGRATE_MOVABLE of free_list although
> the pageblock's migratetype of the page is MIGRATE_ISOLATE.
> 
> The race could be detected by get_freepage_migratetype
> in __test_page_isolated_in_pageblock. If it is detected, now EBUSY
> gets bubbled all the way up and the hotplug operations fails.
> 
> But better idea is instead of returning and failing memory-hotremove,
> move the free page to the correct list at the time it is detected.
> It could enhance memory-hotremove operation success ratio although
> the race is really rare.
> 
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Sounds reasonable. Thank you very much !

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
