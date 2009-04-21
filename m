Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 114906B004F
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 21:20:01 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L1KIQN000988
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 10:20:18 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 078FA45DD76
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:20:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D97C045DD75
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:20:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB7551DB8013
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:20:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D473E18002
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:20:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: AIM9 from 2.6.22 to 2.6.29
In-Reply-To: <alpine.DEB.1.10.0904201300140.1585@qirst.com>
References: <20090418154207.1260.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0904201300140.1585@qirst.com>
Message-Id: <20090421101855.F10D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 10:20:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Sat, 18 Apr 2009, KOSAKI Motohiro wrote:
> 
> > > Here is a list of AIM9 results for all kernels between 2.6.22 2.6.29:
> > >
> > > Significant regressions:
> > >
> > > creat-clo
> > > page_test
> >
> > I'm interest to it.
> > How do I get AIM9 benchmark?
> 
> Checkout reaim9 on sourceforge.

sourceforge search engine don't search reaim9 ;)


http://sourceforge.net/search/?words=aim9&type_of_search=soft&pmode=0&words=reaim9&Search=Search


> > and, Can you compare CONFIG_UNEVICTABLE_LRU is y and n?
> 
> Sure.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
