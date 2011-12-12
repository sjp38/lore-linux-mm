Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 8AC126B009D
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 19:55:21 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 277AD3EE0AE
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:55:20 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 07DD345DEEF
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:55:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E278745DEEB
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:55:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D3B551DB8038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:55:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B7631DB803E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:55:19 +0900 (JST)
Date: Mon, 12 Dec 2011 09:54:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V2] vmscan/trace: Add 'active' and 'file' info to
 trace_mm_vmscan_lru_isolate.
Message-Id: <20111212095406.3d96a474.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1323614784-2924-1-git-send-email-tm@tao.ma>
References: <1323614784-2924-1-git-send-email-tm@tao.ma>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tao Ma <tm@tao.ma>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, 11 Dec 2011 22:46:24 +0800
Tao Ma <tm@tao.ma> wrote:

> From: Tao Ma <boyu.mt@taobao.com>
> 
> In trace_mm_vmscan_lru_isolate, we don't output 'active' and 'file'
> information to the trace event and it is a bit inconvenient for the
> user to get the real information(like pasted below).
> mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
> nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
> 
> So this patch adds these 2 info to the trace event and it now looks like:
> mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
> nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0 active=1 file=0
> 
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Tao Ma <boyu.mt@taobao.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
