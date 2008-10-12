Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9CDWAvD003640
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 12 Oct 2008 22:32:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E9D331B801E
	for <linux-mm@kvack.org>; Sun, 12 Oct 2008 22:32:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C2F3D2DC015
	for <linux-mm@kvack.org>; Sun, 12 Oct 2008 22:32:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 386AD1DB8047
	for <linux-mm@kvack.org>; Sun, 12 Oct 2008 22:32:09 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F4D21DB8045
	for <linux-mm@kvack.org>; Sun, 12 Oct 2008 22:31:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
In-Reply-To: <48F110AA.50609@redhat.com>
References: <20081010192125.9a54cc22.akpm@linux-foundation.org> <48F110AA.50609@redhat.com>
Message-Id: <20081012222727.1815.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 12 Oct 2008 22:31:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, nickpiggin@yahoo.com.au, linux-mm@kvack.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Hi,

I mesured mmotm-10-10 today.
So, it seems very good result.


mainline:     Throughput 13.4231 MB/sec  4000 clients  4000 procs  max_latency=1421988.159 ms
mmotm-10-02:  Throughput  7.0354 MB/sec  4000 clients  4000 procs  max_latency=2369213.380 ms
mmotm-10-10:  Throughput 14.2802 MB/sec  4000 clients  4000 procs  max_latency=1564716.557 ms


Thanks!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
