Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9CE7D6B00A1
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 20:22:52 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1J1MQb8001257
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 19 Feb 2009 10:22:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 61C7445DE4F
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 10:22:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 48BE145DD72
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 10:22:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 34091E18001
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 10:22:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E43D01DB8037
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 10:22:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 1/7] slab: introduce kzfree()
In-Reply-To: <1234954488.24030.46.camel@penberg-laptop>
References: <499BE7F8.80901@csr.com> <1234954488.24030.46.camel@penberg-laptop>
Message-Id: <20090219101336.9556.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Feb 2009 10:22:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: kosaki.motohiro@jp.fujitsu.com, David Vrabel <david.vrabel@csr.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> On Wed, 2009-02-18 at 10:50 +0000, David Vrabel wrote:
> > Johannes Weiner wrote:
> > > +void kzfree(const void *p)
> > 
> > Shouldn't this be void * since it writes to the memory?
> 
> No. kfree() writes to the memory as well to update freelists, poisoning
> and such so kzfree() is not at all different from it.

I don't think so. It's debetable thing.

poisonig is transparent feature from caller.
but the caller of kzfree() know to fill memory and it should know.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
