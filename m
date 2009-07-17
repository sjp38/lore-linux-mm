Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5CC7E6B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 20:16:18 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6H0GL4c017984
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Jul 2009 09:16:21 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B80592AEA82
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:16:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 94ABB45DE4D
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:16:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 72D0F1DB803E
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:16:20 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 02F491DB803F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:16:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] mm: shrink_inactive_lis() nr_scan accounting fix fix
In-Reply-To: <20090716125516.GB28895@localhost>
References: <20090716095241.9D0D.A69D9226@jp.fujitsu.com> <20090716125516.GB28895@localhost>
Message-Id: <20090717091439.A906.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Jul 2009 09:16:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Not a newly introduced problem, but this early break might under scan
> the list, if (max_scan > swap_cluster_max).  Luckily the only two
> callers all call with (max_scan <= swap_cluster_max).
> 
> What shall we do? The comprehensive solution may be to
> - remove the big do-while loop
> - replace sc->swap_cluster_max => max_scan
> - take care in the callers to not passing small max_scan values
> 
> Or to simply make this function more robust like this?

Sorry, I haven't catch your point. Can you please tell me your worried
scenario?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
