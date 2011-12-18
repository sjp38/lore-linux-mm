Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id A251C6B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 19:49:22 -0500 (EST)
Received: by ghrr18 with SMTP id r18so3340442ghr.14
        for <linux-mm@kvack.org>; Sat, 17 Dec 2011 16:49:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1323875693-3504-1-git-send-email-tm@tao.ma>
References: <20111213164507.fbee477c.akpm@linux-foundation.org>
	<1323875693-3504-1-git-send-email-tm@tao.ma>
Date: Sun, 18 Dec 2011 09:49:20 +0900
Message-ID: <CAEwNFnBrczRf6XMeN6EaTkANVPdzLeAXqahJxAWPGz3GDW5nWg@mail.gmail.com>
Subject: Re: [PATCH v3] vmscan/trace: Add 'file' info to trace_mm_vmscan_lru_isolate.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tao Ma <tm@tao.ma>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Dec 15, 2011 at 12:14 AM, Tao Ma <tm@tao.ma> wrote:
> From: Tao Ma <boyu.mt@taobao.com>
>
> In trace_mm_vmscan_lru_isolate, we don't output 'file'
> information to the trace event and it is a bit inconvenient for the
> user to get the real information(like pasted below).
> mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
> nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
>
> 'active' can be gotten by analyzing mode(Thanks go to Minchan and Mel),
> So this patch adds 'file' to the trace event and it now looks like:
> mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
> nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0 file=0
>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Tao Ma <boyu.mt@taobao.com>

Andrew pointed out that   trace_mm_vmscan_memcg_isolate is out , Otherwise,
Reviewed-by: Minchan Kim <minchan@kernel.org>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
