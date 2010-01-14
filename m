Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DC5F76B0099
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 02:02:46 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0E72hxg014421
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Jan 2010 16:02:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B088E45DE79
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:02:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 820B145DE4D
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:02:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 667D11DB803F
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:02:43 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 190BF1DB803A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:02:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v5] add MAP_UNLOCKED mmap flag
In-Reply-To: <20100114065008.GC18808@redhat.com>
References: <20100114092845.D719.A69D9226@jp.fujitsu.com> <20100114065008.GC18808@redhat.com>
Message-Id: <20100114155229.6735.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Jan 2010 16:02:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> On Thu, Jan 14, 2010 at 09:31:03AM +0900, KOSAKI Motohiro wrote:
> > > If application does mlockall(MCL_FUTURE) it is no longer possible to mmap
> > > file bigger than main memory or allocate big area of anonymous memory
> > > in a thread safe manner. Sometimes it is desirable to lock everything
> > > related to program execution into memory, but still be able to mmap
> > > big file or allocate huge amount of memory and allow OS to swap them on
> > > demand. MAP_UNLOCKED allows to do that.
> > >  
> > > Signed-off-by: Gleb Natapov <gleb@redhat.com>
> > > ---
> > > 
> > > I get reports that people find this useful, so resending.
> > 
> > This description is still wrong. It doesn't describe why this patch is useful.
> > 
> I think the text above describes the feature it adds and its use
> case quite well. Can you elaborate what is missing in your opinion,
> or suggest alternative text please?

My point is, introducing mmap new flags need strong and clearly use-case.
All patch should have good benefit/cost balance. the code can describe the cost,
but the benefit can be only explained by the patch description.

I don't think this poor description explained bit benefit rather than cost.
you should explain why this patch is useful and not just pretty toy.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
