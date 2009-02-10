Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DC8AC6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 07:35:55 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1ACZqV3022795
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 21:35:52 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C000145DE51
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:35:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A13C245DE55
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:35:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89D3A1DB803B
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:35:51 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 480D51DB803F
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:35:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] vmscan: initialize sc->nr_reclaimed in do_try_to_free_pages()
In-Reply-To: <28c262360902100431l4a5977e7p9c5152882f09dcf9@mail.gmail.com>
References: <20090210210520.7004.KOSAKI.MOTOHIRO@jp.fujitsu.com> <28c262360902100431l4a5977e7p9c5152882f09dcf9@mail.gmail.com>
Message-Id: <20090210213502.7007.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 21:35:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hmm.. You're right.
> As Johannes pointed out,
> too many page shrinking can degrade resume performance.
> 
> We need to bale out in shrink_all_memory.
> Other people, thought ?

shrink_all_zones() already have bale-out code ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
