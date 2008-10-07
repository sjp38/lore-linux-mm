Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m97EQxgG028838
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 7 Oct 2008 23:26:59 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D93A42AC026
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 23:26:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B267412C045
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 23:26:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D4781DB8037
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 23:26:58 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 57FB71DB803E
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 23:26:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: split-lru performance mesurement part2
In-Reply-To: <20081004232549.CE53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081003153810.5dd0a33e@bree.surriel.com> <20081004232549.CE53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081007231851.3B88.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  7 Oct 2008 23:26:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Hi

> yup,
> I know many people want to other benchmark result too.
> I'll try to mesure other bench at next week.

I ran another benchmark today.
I choice dbench because dbench is one of most famous and real workload like i/o benchmark.


% dbench client.txt 4000

mainline:  Throughput 13.4231 MB/sec  4000 clients  4000 procs  max_latency=1421988.159 ms
mmotm(*):  Throughput  7.0354 MB/sec  4000 clients  4000 procs  max_latency=2369213.380 ms

(*) mmotm 2/Oct + Hugh's recently slub fix


Wow!
mmotm is slower than mainline largely (about half performance).

Therefore, I mesured it on "mainline + split-lru(only)" build.


mainline + split-lru(only): Throughput 14.4062 MB/sec  4000 clients  4000 procs  max_latency=1152231.896 ms


OK!
split-lru outperform mainline from viewpoint of both throughput and latency :)



However, I don't understand why this regression happend.
Do you have any suggestion?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
