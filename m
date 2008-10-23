Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9N2AHsn021360
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 23 Oct 2008 11:10:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 397372AC026
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 11:10:17 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1360712C044
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 11:10:17 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 0178B1DB803E
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 11:10:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id B3EF11DB8037
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 11:10:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 0/3] activate pages in batch
In-Reply-To: <87prlsjcjg.fsf@saeurebad.de>
References: <20081023104002.1CEA.KOSAKI.MOTOHIRO@jp.fujitsu.com> <87prlsjcjg.fsf@saeurebad.de>
Message-Id: <20081023110723.1CF0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 23 Oct 2008 11:10:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >> Instead of re-acquiring the highly contented LRU lock on every single
> >> page activation, deploy an extra pagevec to do page activation in
> >> batch.
> >
> > Do you have any mesurement result?
> 
> Not yet, sorry.
> 
> Spinlocks are no-ops on my architecture, though, so the best I can come
> up with is results from emulating an SMP machine, would that be okay?

it's not ok..

if you can explain best mesurement way, I can mesure on 8 way machine :)
(but, of cource, I should mesure your madv_sequence patch earlier)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
