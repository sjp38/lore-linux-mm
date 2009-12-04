Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1E6036B003D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 00:06:11 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB4568dc014657
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Dec 2009 14:06:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C04C045DE53
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 14:06:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 92FE145DE4F
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 14:06:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 700211DB8041
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 14:06:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 25C321DB8037
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 14:06:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
In-Reply-To: <20091203134610.586E.A69D9226@jp.fujitsu.com>
References: <20091202125501.GD28697@random.random> <20091203134610.586E.A69D9226@jp.fujitsu.com>
Message-Id: <20091204135938.5886.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  4 Dec 2009 14:06:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Umm?? Personally I don't like knob. If you have problematic workload,
> please tell it us. I will try to make reproduce environment on my box.
> If current code doesn't works on KVM or something-else, I really want
> to fix it.
> 
> I think Larry's trylock idea and your 64 young bit idea can be combinate.
> I only oppose the page move to inactive list without clear young bit. IOW,
> if VM pressure is very low and the page have lots young bit, the page should
> go back active list although trylock(ptelock) isn't contended.
> 
> But unfortunatelly I don't have problem workload as you mentioned. Anyway
> we need evaluate way to your idea. We obviouslly more info.

[Off topic start]

Windows kernel have zero page thread and it clear the pages in free list
periodically. because many windows subsystem prerefer zero filled page.
hen, if we use windows guest, zero filled page have plenty mapcount rather
than other typical sharing pages, I guess.

So, can we mark as unevictable to zero filled ksm page? 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
