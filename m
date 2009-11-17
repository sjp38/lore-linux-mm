Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 989206B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 05:24:53 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAHAOoYB011230
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 19:24:51 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D6C4245DE87
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 19:24:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6D7945DE60
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 19:24:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E6E71DB803F
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 19:24:45 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C3850E1800F
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 19:24:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] Kill PF_MEMALLOC abuse
In-Reply-To: <20091117101526.GA4797@infradead.org>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com> <20091117101526.GA4797@infradead.org>
Message-Id: <20091117192232.3DF9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 19:24:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, Nov 17, 2009 at 04:16:04PM +0900, KOSAKI Motohiro wrote:
> > Some subsystem paid attention (1) only, and start to use PF_MEMALLOC abuse.
> > But, the fact is, PF_MEMALLOC is the promise of "I have lots freeable memory.
> > if I allocate few memory, I can return more much meory to the system!".
> > Non MM subsystem must not use PF_MEMALLOC. Memory reclaim
> > need few memory, anyone must not prevent it. Otherwise the system cause
> > mysterious hang-up and/or OOM Killer invokation.
> 
> And that's exactly the promises xfsbufd gives.  It writes out dirty
> metadata buffers and will free lots of memory if you kick it. 

if xfsbufd doesn't only write out dirty data but also drop page,
I agree you. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
