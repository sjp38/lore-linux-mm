Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9H9W9Cm026407
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Oct 2008 18:32:09 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 724BC240047
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 18:32:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49A872DC078
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 18:32:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 15A691DB8046
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 18:32:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C5EA61DB803E
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 18:32:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch][rfc] mm: have expand_stack honour VM_LOCKED
In-Reply-To: <20081017090813.GA32554@wotan.suse.de>
References: <20081017142346.FAA6.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081017090813.GA32554@wotan.suse.de>
Message-Id: <20081017182737.E23C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Oct 2008 18:32:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Hi Nick,
> > 
> > > Is this valid?
> > > 
> > > 
> > > It appears that direct callers of expand_stack may not properly lock the newly
> > > expanded stack if they don't call make_pages_present (page fault handlers do
> > > this).
> > 
> > When happend this issue?
> > 
> > I think...
> > 
> > case 1. explit mlock to stack 
> > 
> >    1. mlock to stack
> >         -> make_pages_present is called via mlock(2).
> >    2. stack increased
> >         -> no page fault happened.
> > 
> > case 2. swapout and mlock stack
> > 
> >    1. stack swap out
> >    2. mlock to stack
> >         -> the page doesn't swap in at the time.
> >    3. page fault in the stack
> >         -> the page swap in
> >            (no need make_present_page())
> > 
> > 
> > So, it seems this patch isn't necessary.
> 
> What if you you page fault the stack further than a single page down?
> 

I see. thanks.

But unfortunately, this patch conflicted against unevictable patch series.
I'll make for -mm version patch few days after if you don't like do that.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
