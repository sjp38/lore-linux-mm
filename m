Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAQ0DXsL024875
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 26 Nov 2008 09:13:34 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 96D6345DD7B
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 09:13:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C28845DD78
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 09:13:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E8831DB803B
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 09:13:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E510F1DB803F
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 09:13:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] memcg reclaim shouldn't change zone->recent_rotated statics.
In-Reply-To: <20081125155422.6ab07caf.akpm@linux-foundation.org>
References: <20081125121842.26C5.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081125155422.6ab07caf.akpm@linux-foundation.org>
Message-Id: <20081126091027.3CA6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 26 Nov 2008 09:13:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 25 Nov 2008 12:22:53 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > +	if (scan_global_lru(sc))
> 
> mutter.  scan_global_lru() is a terrible function name.  Anyone reading
> that code would expect that this function, umm, scans the global LRU.

yup.

> gcc has a nice convention wherein such functions have a name ending in
> "_p" (for "predicate").  Don't do this :)

however, "_p" isn't linux convention.
so, I like "is_" or "can_" (or likes somethingelse) prefix :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
