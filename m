Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id DF8E56B0070
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 06:11:35 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 81CBA3EE0C1
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:11:34 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 68B3845DEB8
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:11:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E67345DEB2
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:11:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 347291DB8038
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:11:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BB35E1DB803F
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:11:33 +0900 (JST)
Message-ID: <5007DCBF.7070804@jp.fujitsu.com>
Date: Thu, 19 Jul 2012 19:09:03 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3 v3] memory-hotplug: fix kswapd looping forever problem
References: <1342061449-29590-1-git-send-email-minchan@kernel.org> <1342061449-29590-3-git-send-email-minchan@kernel.org> <20120712140154.72766586.akpm@linux-foundation.org>
In-Reply-To: <20120712140154.72766586.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar@ap.sony.com>


> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: memory-hotplug-fix-kswapd-looping-forever-problem-fix
>
> simplify nr_zone_isolate_freepages(), rework zone_watermark_ok_safe() comment, simplify set_pageblock_isolate() and restore_pageblock_isolate().
>
> Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
