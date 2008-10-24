Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9O5TKWa011077
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 24 Oct 2008 14:29:20 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DE0E2AC02D
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 14:29:20 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F342612C052
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 14:29:19 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id D9B0F1DB8042
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 14:29:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 9076B1DB803A
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 14:29:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
In-Reply-To: <20081024045547.GA24555@wotan.suse.de>
References: <20081024135149.9C46.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081024045547.GA24555@wotan.suse.de>
Message-Id: <20081024140723.9C49.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 24 Oct 2008 14:29:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > > I don't see a better way to solve it, other than avoiding lru_add_drain_all
> > 
> > Well,
> > 
> > Unfortunately, lru_add_drain_all is also used some other VM place
> > (page migration and memory hotplug).
> > and page migration's usage is the same of this mlock usage.
> > (1. grab mmap_sem  2.  call lru_add_drain_all)
> > 
> > Then, change mlock usage isn't solution ;-)
> 
> No, not mlock alone.

Ah, I see.
It seems difficult but valuable. I'll think this way for a while.


Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
