Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 99D836B003D
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 21:42:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L1hHoE012432
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 10:43:17 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D7F245DE51
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:43:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CA6845DD79
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:43:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4863B1DB8038
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:43:17 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EE01E1DB803B
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:43:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my case?
In-Reply-To: <49EC44C6.1010603@gmail.com>
References: <20090420181436.61AE.A69D9226@jp.fujitsu.com> <49EC44C6.1010603@gmail.com>
Message-Id: <20090421104225.F116.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 10:43:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > but, user process still can call munlock. it cause disaster.
> > I still think -EINVAL is better.
> >   
> Why the user process call munlock? VLC or Mplayer do not call it, so I 
> don't worry about that.
> 
> Our video card is still not on sale.So I can wait until the bug is fixed. :)
> If there is no method to bypass the problem in future,I will return -EINVAL.

We don't assume any userspace behavior in kernel. but you can ignore
our recommendation, of cource :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
