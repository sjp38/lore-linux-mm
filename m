Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8EC2F6B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 19:25:53 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5UNQdou006055
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Jul 2009 08:26:40 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8751D45DE51
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 08:26:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6202445DE55
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 08:26:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 467EA1DB8041
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 08:26:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 050BB1DB803E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 08:26:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Show kernel stack usage to /proc/meminfo and OOM log
In-Reply-To: <alpine.DEB.1.10.0906301011210.6124@gentwo.org>
References: <20090630150035.A738.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0906301011210.6124@gentwo.org>
Message-Id: <20090701082531.85C2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Jul 2009 08:26:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

> On Tue, 30 Jun 2009, KOSAKI Motohiro wrote:
> 
> > +static void account_kernel_stack(struct thread_info *ti, int on)
> 
> static inline?

gcc automatically inlined, IMHO.

> > +{
> > +	struct zone* zone = page_zone(virt_to_page(ti));
> > +	int sign = on ? 1 : -1;
> > +	long acct = sign * (THREAD_SIZE / PAGE_SIZE);
> 
> int pages = THREAD_SIZE / PAGE_SIZE;
> 
> ?

Will fix. thanks cleaner code advise.

> 
> > +
> > +	mod_zone_page_state(zone, NR_KERNEL_STACK, acct);
> 
> mod_zone_page_state(zone, NR_KERNEL_STACK, on ? pages : -pages);

yes, will fix.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
