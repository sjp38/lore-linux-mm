Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 07FD06B01F0
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 00:22:08 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7Q4M7iB020023
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 26 Aug 2010 13:22:07 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C894745DE61
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:22:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AB8E45DE55
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:22:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 29AE5E08005
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:22:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D9678E08004
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:22:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] writeback: remove the internal 5% low bound on dirty_ratio
In-Reply-To: <20100826113649.687b453a@notabene>
References: <20100826012945.GA7859@localhost> <20100826113649.687b453a@notabene>
Message-Id: <20100826132046.F670.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 26 Aug 2010 13:22:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Con Kolivas <kernel@kolivas.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@fromorbit.com" <david@fromorbit.com>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

> > writeback: remove the internal 5% low bound on dirty_ratio
> > 
> > The dirty_ratio was silently limited in global_dirty_limits() to >= 5%.
> > This is not a user expected behavior. And it's inconsistent with
> > calc_period_shift(), which uses the plain vm_dirty_ratio value.
> > 
> > Let's rip the internal bound.
> > 
> > At the same time, fix balance_dirty_pages() to work with the
> > dirty_thresh=0 case. This allows applications to proceed when
> > dirty+writeback pages are all cleaned.
> 
> And ">" fits with the name "exceeded" better than ">=" does.  I think it is
> an aesthetic improvement as well as a functional one.
> 
> Reviewed-by: NeilBrown <neilb@suse.de>

I agree :)
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
