Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA59tv8e001575
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 5 Nov 2008 18:55:57 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2698D45DE5C
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 18:55:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F28045DE54
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 18:55:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 256141DB8049
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 18:55:55 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 804C01DB804F
	for <linux-mm@kvack.org>; Wed,  5 Nov 2008 18:55:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
In-Reply-To: <1225878704.7803.2771.camel@twins>
References: <2f11576a0810290020i362441edkb494b10c10b17401@mail.gmail.com> <1225878704.7803.2771.camel@twins>
Message-Id: <20081105185458.968B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  5 Nov 2008 18:55:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, npiggin@suse.de, linux-kernel@vger.kernel.org, hugh@veritas.com, torvalds@linux-foundation.org, riel@redhat.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, 2008-10-29 at 16:20 +0900, KOSAKI Motohiro wrote:
> > > I guess we should document our newly discovered schedule_on_each_cpu()
> > > problems before we forget about it and later rediscover it.
> > 
> > Now, schedule_on_each_cpu() is only used by lru_add_drain_all().
> > and smp_call_function() is better way for cross call.
> > 
> > So I propose
> >    1. lru_add_drain_all() use smp_call_function()
> >    2. remove schedule_on_each_cpu()
> > 
> > 
> > Thought?
> 
> At the very least that will not solve the problem on -rt where a lot of
> the smp_call_function() users are converted to schedule_on_each_cpu().

yup.
Now, I testing "simple dropping lru_add_drain_all() in mlock path" patch.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
