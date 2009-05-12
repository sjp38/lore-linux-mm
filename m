Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 08C2A6B005A
	for <linux-mm@kvack.org>; Mon, 11 May 2009 23:00:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4C30s1d022490
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 May 2009 12:00:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D925845DD83
	for <linux-mm@kvack.org>; Tue, 12 May 2009 12:00:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DEA145DD81
	for <linux-mm@kvack.org>; Tue, 12 May 2009 12:00:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3500A1DB8041
	for <linux-mm@kvack.org>; Tue, 12 May 2009 12:00:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B8D721DB803F
	for <linux-mm@kvack.org>; Tue, 12 May 2009 12:00:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class citizen
In-Reply-To: <20090512025246.GC7518@localhost>
References: <20090508125859.210a2a25.akpm@linux-foundation.org> <20090512025246.GC7518@localhost>
Message-Id: <20090512120002.D616.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 May 2009 12:00:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> side effects
> ------------
> 
> This patch is safe in general, it restores the pre-2.6.28 mmap() behavior
> but in a much smaller and well targeted scope.
> 
> One may worry about some one to abuse the PROT_EXEC heuristic.  But as
> Andrew Morton stated, there are other tricks to getting that sort of boost.
> 
> Another concern is the PROT_EXEC mapped pages growing large in rare cases,
> and therefore hurting reclaim efficiency. But a sane application targeted for
> large audience will never use PROT_EXEC for data mappings. If some home made
> application tries to abuse that bit, it shall be aware of the consequences,
> which won't be disastrous even in the worst case.

ok, I lose.
if you can post good mesurement result, I'll ack this.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
