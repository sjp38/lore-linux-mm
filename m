Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A6C6F6B009A
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:02:59 -0400 (EDT)
Date: Thu, 16 Jul 2009 18:01:39 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: Warn once when a page is freed with PG_mlocked set V2
Message-ID: <20090716160139.GB1883@cmpxchg.org>
References: <alpine.DEB.1.10.0907151027410.23643@gentwo.org> <20090715220445.GA1823@cmpxchg.org> <20090716163537.9D3D.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907160949470.32382@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0907160949470.32382@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Jiri Slaby <jirislaby@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 16, 2009 at 09:54:49AM -0400, Christoph Lameter wrote:
> On Thu, 16 Jul 2009, KOSAKI Motohiro wrote:
> 
> > I like this patch. but can you please separate two following patches?
> >   - introduce __TESTCLEARFLAG()
> >   - non-atomic test-clear of PG_mlocked on free
> 
> That would mean introducing the macro without any use case? It is fine the
> way it is I think.

Yeah, it's borderline.  In any case, I have the split version here as
well.  Andrew, you choose :)

> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

Thanks,

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
