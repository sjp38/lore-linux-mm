Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 87FD46B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 20:17:40 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6H0Hipv026032
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Jul 2009 09:17:44 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A718745DE55
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:17:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 80D6445DE52
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:17:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5765BE08002
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:17:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F1E3D1DB8038
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:17:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: Warn once when a page is freed with PG_mlocked set V2
In-Reply-To: <20090716160139.GB1883@cmpxchg.org>
References: <alpine.DEB.1.10.0907160949470.32382@gentwo.org> <20090716160139.GB1883@cmpxchg.org>
Message-Id: <20090717091653.A909.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Jul 2009 09:17:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Jiri Slaby <jirislaby@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Thu, Jul 16, 2009 at 09:54:49AM -0400, Christoph Lameter wrote:
> > On Thu, 16 Jul 2009, KOSAKI Motohiro wrote:
> > 
> > > I like this patch. but can you please separate two following patches?
> > >   - introduce __TESTCLEARFLAG()
> > >   - non-atomic test-clear of PG_mlocked on free
> > 
> > That would mean introducing the macro without any use case? It is fine the
> > way it is I think.
> 
> Yeah, it's borderline.  In any case, I have the split version here as
> well.  Andrew, you choose :)
> 
> > Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Thanks,

OK, I can agree with Christoph. you don't need change the patch.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
