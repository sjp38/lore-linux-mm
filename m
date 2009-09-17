Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 51AD96B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 22:43:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H2htD1014303
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Sep 2009 11:43:55 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A12345DE5C
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:43:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EC0645DE57
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:43:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E85CFE38009
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:43:49 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 53126EF8003
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:43:49 +0900 (JST)
Date: Thu, 17 Sep 2009 11:41:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/3][mmotm] showing size of kcore  (Was Re: kcore patches
 (was Re: 2.6.32 -mm merge plans)
Message-Id: <20090917114138.e14a1183.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
References: <2375c9f90909160235m1f052df0qb001f8243ed9291e@mail.gmail.com>
	<1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Am?rico_Wang <xiyou.wangcong@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Sep 2009 20:17:52 +0900 (JST)
"KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> But for now, we have to use some fixed value....and using above
> patch for 2.6.31 is not very bad.
> 

This set is based on mmotm's kcore patch stack.
So, just for discussing. 

  [1/3] ... clean up (tiny bug fix)
  [2/3] ... show size of /proc/kcore
  [3/3] ... update kcore size at memory hotplug.

After patches, /proc/kcore's size is as following.
==
[kamezawa@bluextal mmotm-2.6.31-Sep14]$ ls -l /proc/kcore
-r-------- 1 root root 140737486266368 2009-09-17 11:53 /proc/kcore
[kamezawa@bluextal mmotm-2.6.31-Sep14]$
==
I'm not sure how this value is useful...but..hmm..better than zero ?
(The reason of very big value is because vmalloc area is too large.)


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
