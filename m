Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BF5DA6B004F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 06:30:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3LAVPJI031770
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 19:31:25 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F268745DE76
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:31:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A5DC245DE71
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:31:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E9D71DB8046
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:31:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C2C61DB803C
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:31:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 12/25] Remove a branch by assuming __GFP_HIGH == ALLOC_HIGH
In-Reply-To: <20090421180757.F145.A69D9226@jp.fujitsu.com>
References: <1240266011-11140-13-git-send-email-mel@csn.ul.ie> <20090421180757.F145.A69D9226@jp.fujitsu.com>
Message-Id: <20090421193030.F16B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 19:31:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > @@ -1639,8 +1639,8 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
> >  	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
> >  	 */
> > -	if (gfp_mask & __GFP_HIGH)
> > -		alloc_flags |= ALLOC_HIGH;
> > +	VM_BUG_ON(__GFP_HIGH != ALLOC_HIGH);

Oops, I forgot said one comment.
BUILD_BUG_ON() is better?


> > +	alloc_flags |= (gfp_mask & __GFP_HIGH);
> >  
> >  	if (!wait) {
> >  		alloc_flags |= ALLOC_HARDER;
> 
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
