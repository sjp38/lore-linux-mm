Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 898636B0044
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 23:34:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0R4YMUx016217
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 27 Jan 2009 13:34:23 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BE8FE45DE57
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 13:34:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C1D145DE51
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 13:34:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 83898E38002
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 13:34:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3736EE18007
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 13:34:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC v2][PATCH]page_fault retry with NOPAGE_RETRY
In-Reply-To: <20090126235715.GB8726@elte.hu>
References: <20090126155246.2d7df309.akpm@linux-foundation.org> <20090126235715.GB8726@elte.hu>
Message-Id: <20090128131715.D45E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 27 Jan 2009 13:34:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mikew@google.com, rientjes@google.com, rohitseth@google.com, hugh@veritas.com, a.p.zijlstra@chello.nl, hpa@zytor.com, edwintorok@gmail.com, lee.schermerhorn@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

> 
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > I think that a good way to present this is as a preparatory patch: 
> > "convert the fourth argument to handle_mm_fault() from a boolean to a 
> > flags word".  That would be a simple do-nothing patch which affects all 
> > architectures and which ideally would break the build at any unconverted 
> > code sites.  (Change the argument order?)
> 
> why not do what i suggested: refactor do_page_fault() into a platform 
> specific / kernel-internal faults and into a generic-user-pte function. 
> That alone would increase readability i suspect.
> 
> Then the 'retry' is multiple calls from handle_pte_fault().
> 
> Or something like that.
> 
> It looks wrong to me to pass another flag through this hot codepath, just 
> to express a property that the _highlevel_ code is interested in.

I like this idea :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
