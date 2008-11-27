Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAR3oX7K026336
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 27 Nov 2008 12:50:34 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AE5E245DE4F
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 12:50:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FD9745DE4E
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 12:50:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 74C441DB8038
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 12:50:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3367D1DB8040
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 12:50:33 +0900 (JST)
Date: Thu, 27 Nov 2008 12:49:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg reclaim shouldn't change zone->recent_rotated
 statics.
Message-Id: <20081127124946.912541e2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081125155422.6ab07caf.akpm@linux-foundation.org>
References: <20081125121842.26C5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081125155422.6ab07caf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Nov 2008 15:54:22 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 25 Nov 2008 12:22:53 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > +	if (scan_global_lru(sc))
> 
> mutter.  scan_global_lru() is a terrible function name.  Anyone reading
> that code would expect that this function, umm, scans the global LRU.
> 
> gcc has a nice convention wherein such functions have a name ending in
> "_p" (for "predicate").  Don't do this :)
> 

Hmm, I'll prepare renaming patch.

scan_global_lru_p() ? or under_scanning_global_lru() ?


Thanks,
-Kame

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
