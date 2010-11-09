Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 24FA66B00A0
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 05:27:42 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA9ARd22022953
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 19:27:39 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AF7845DE51
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 19:27:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DAC645DE4E
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 19:27:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EF9F1DB8019
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 19:27:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 03EAA1DB8015
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 19:27:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 61 of 66] use compaction for GFP_ATOMIC order > 0
In-Reply-To: <b540c09bfe5160120952.1288798116@v2.random>
References: <patchbomb.1288798055@v2.random> <b540c09bfe5160120952.1288798116@v2.random>
Message-Id: <20101109151440.BC75.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Nov 2010 19:27:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> This takes advantage of memory compaction to properly generate pages of order >
> 0 if regular page reclaim fails and priority level becomes more severe and we
> don't reach the proper watermarks.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

First, I don't think this patch is related to GFP_ATOMIC. So, I think the 
patch title is a bit misleading.

Second, this patch has two changes. 1) remove PAGE_ALLOC_COSTLY_ORDER 
threshold 2) implement background compaction. please separate them.

Third, This patch makes a lot of PFN order page scan and churn LRU
aggressively. I'm not sure this aggressive lru shuffling is safe and
works effective. I hope you provide some demonstration and/or show 
benchmark result.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
