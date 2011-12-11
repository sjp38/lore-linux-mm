Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 682F86B006E
	for <linux-mm@kvack.org>; Sat, 10 Dec 2011 20:39:50 -0500 (EST)
Message-ID: <4EE409CA.3080404@tao.ma>
Date: Sun, 11 Dec 2011 09:39:22 +0800
From: Tao Ma <tm@tao.ma>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan/trace: Add 'active' and 'file' info to trace_mm_vmscan_lru_isolate.
References: <1323533451-2953-1-git-send-email-tm@tao.ma> <4EE388D0.2090608@gmail.com>
In-Reply-To: <4EE388D0.2090608@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 12/11/2011 12:29 AM, KOSAKI Motohiro wrote:
> (12/10/11 11:10 AM), Tao Ma wrote:
>> From: Tao Ma<boyu.mt@taobao.com>
>>
>> In trace_mm_vmscan_lru_isolate, we don't output 'active' and 'file'
>> information to the trace event and it is a bit inconvenient for the
>> user to get the real information(like pasted below).
>> mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
>> nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
>>
>> So this patch adds these 2 info to the trace event and it now looks like:
>> mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
>> nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0 lru=1,0
> 
> addition is ok to me. but lru=1,0 is not human readable. I suspect
> people will easily forget which value is active.
Sure, I can change it to something like "active=1,file=0".
Maybe I am too worried about the memory used.
So if there is no objection, I will change it.

Thanks
Tao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
