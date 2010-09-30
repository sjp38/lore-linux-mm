Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5E2BB6B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:04:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8U349YW001134
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 30 Sep 2010 12:04:09 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 065F045DE57
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 12:04:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC87145DE4F
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 12:04:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B1965E08001
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 12:04:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BB701DB8038
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 12:04:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch]vmscan: protect exectuable page from inactive list scan
In-Reply-To: <20100930025750.GA10456@localhost>
References: <20100930112408.2A94.A69D9226@jp.fujitsu.com> <20100930025750.GA10456@localhost>
Message-Id: <20100930120554.2A97.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 30 Sep 2010 12:04:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Li, Shaohua" <shaohua.li@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > > > PTE-referenced PageAnon() pages are activated unconditionally a few
> > > > lines further up, so the page_is_file_cache() check filters only shmem
> > > > pages.  I doubt this was your intention...?
> > > This is intented. the executable page protect is just to protect
> > > executable file pages. please see 8cab4754d24a0f.
> > 
> > 8cab4754d24a0f was using !PageAnon() but your one are using page_is_file_cache.
> > 8cab4754d24a0f doesn't tell us the reason of the change, no?
> 
> What if the executable file happen to be on tmpfs?  The !PageAnon()
> test also covers that case. The page_is_file_cache() test here seems
> unnecessary. And it looks better to move the VM_EXEC test above the
> SetPageReferenced() line to avoid possible side effects.

Both agree :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
