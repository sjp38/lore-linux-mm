Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0E2986B00BF
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 20:50:18 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 924043EE0BD
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 10:50:16 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 746D345DE59
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 10:50:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5809345DE56
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 10:50:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 49FC7E18002
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 10:50:16 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 15BB6E08004
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 10:50:16 +0900 (JST)
Date: Tue, 4 Jan 2011 10:44:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 6/7] Good bye remove_from_page_cache
Message-Id: <20110104104428.d3ff3aca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <3733d2c036b930eba792e12c824516c04988556e.1293982522.git.minchan.kim@gmail.com>
References: <cover.1293982522.git.minchan.kim@gmail.com>
	<3733d2c036b930eba792e12c824516c04988556e.1293982522.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon,  3 Jan 2011 00:44:35 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Now delete_from_page_cache replaces remove_from_page_cache.
> So we remove remove_from_page_cache so fs or something out of
> mainline will notice it when compile time and can fix it.
> 
> Cc: Christoph Hellwig <hch@infradead.org>
> Acked-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
