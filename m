Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3B2805F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 03:41:43 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3E7gJEb022502
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Apr 2009 16:42:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 388CE2AEA81
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 16:42:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F01CB1EF082
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 16:42:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CFD181DB8060
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 16:42:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 22E101DB805D
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 16:42:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
In-Reply-To: <20090414072231.GA7001@localhost>
References: <20090414154606.C665.A69D9226@jp.fujitsu.com> <20090414072231.GA7001@localhost>
Message-Id: <20090414163312.C674.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Apr 2009 16:42:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> > > > > - PG_unevictable
> > > > > - PG_mlocked
>  
> How about including PG_unevictable/PG_mlocked?
> They shall be meaningful to administrators.

I explained another mail. please see it.


> > this 9 flags shouldn't exported.
> > I can't imazine administrator use what purpose those flags.
> 
> > > > > - PG_swapcache
> > > > > - PG_swapbacked
> > > > > - PG_poison
> > > > > - PG_compound
> >
> > I can agree this 4 flags.
> > However pagemap lack's hugepage considering.
> > if PG_compound exporting, we need more work.
> 
> You mean to fold PG_head/PG_tail into PG_COMPOUND?
> Yes, that's a good simplification for end users.

Yes, I agree.


> > > > > - PG_NOPAGE: whether the page is present
> > 
> > PM_NOT_PRESENT isn't enough?
> 
> That would not be usable if you are going to do a system wide scan.
> PG_NOPAGE could help differentiate the 'no page' case from 'no flags'
> case.
> 
> However PG_NOPAGE is more about the last resort. The system wide scan
> can be made much more efficient if we know the exact memory layouts.

Yup :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
