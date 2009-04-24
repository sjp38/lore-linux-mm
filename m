Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1FEFD6B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 02:40:45 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3O6fKZN011227
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 24 Apr 2009 15:41:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B06445DD77
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 15:41:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AF4C45DD76
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 15:41:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 547A3E08001
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 15:41:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C6841DB8018
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 15:41:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 18/22] Use allocation flags as an index to the zone watermark
In-Reply-To: <20090423100348.GA26953@csn.ul.ie>
References: <20090423092350.F6E6.A69D9226@jp.fujitsu.com> <20090423100348.GA26953@csn.ul.ie>
Message-Id: <20090424154013.1083.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 24 Apr 2009 15:41:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Considering that they are the same type for elements and arrays, I
> didn't think padding would ever be a problem.
> 
> > However, all gcc version don't do that. I think. but perhaps I missed
> > some minor gcc release..
> > 
> > So, I also like Dave's idea. but it only personal feeling.
> > 
> 
> The tide is against me on this one :).
> 
> How about I roll a patch on top of this set that replaces the union by
> calling all sites? I figure that patch will go through a few revisions before
> people are happy with the final API. However, as the patch wouldn't change
> functionality, I'd like to see this series getting wider testing if possible. The
> replace-union-with-single-array patch can be easily folded in then when
> it settles.
> 
> Sound like a plan?

Yeah, I agree testing is important than ugliness discussion :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
