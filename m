Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9EC1A6B004D
	for <linux-mm@kvack.org>; Mon, 25 May 2009 20:40:18 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4Q0esiu005295
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 26 May 2009 09:40:54 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5040845DE51
	for <linux-mm@kvack.org>; Tue, 26 May 2009 09:40:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AB3A45DE4F
	for <linux-mm@kvack.org>; Tue, 26 May 2009 09:40:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E5F0E18006
	for <linux-mm@kvack.org>; Tue, 26 May 2009 09:40:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B47541DB803E
	for <linux-mm@kvack.org>; Tue, 26 May 2009 09:40:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Warn if we run out of swap space
In-Reply-To: <4A1A057A.3080203@oracle.com>
References: <20090524144056.0849.A69D9226@jp.fujitsu.com> <4A1A057A.3080203@oracle.com>
Message-Id: <20090526093917.6846.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 May 2009 09:40:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> >> @@ -410,6 +411,10 @@ swp_entry_t get_swap_page(void)
> >>  	}
> >>
> >>  	nr_swap_pages++;
> >> +	if (!printed) {
> >> +		printed = 1;
> >> +		printk(KERN_WARNING "All of swap is in use. Some pages cannot be swapped out.");
> >> +	}
> > 
> > Why don't you use WARN_ONCE()?
> 
> Someone earlier in this patch thread (maybe Pavel?) commented that
> WARN_ONCE() would cause a stack dump and that would be too harsh,
> especially for users.  I.e., just the message is needed here, not a
> stack dump.

Ah, makes sense.
I agree with you.

So, adding patch description is better?

> 
> > lumpy reclaim on no swap system makes this warnings, right?
> > if so, I think it's a bit annoy.
> > 
> >>  noswap:
> >>  	spin_unlock(&swap_lock);
> >>  	return (swp_entry_t) {0};



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
