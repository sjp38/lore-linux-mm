Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9H5gpxR009192
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Oct 2008 14:42:51 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CF2A2AC02D
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 14:41:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D856C12C044
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 14:41:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 206B01DB803C
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 14:41:38 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 17D021DB8037
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 14:41:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch][rfc] mm: have expand_stack honour VM_LOCKED
In-Reply-To: <20081017050120.GA28605@wotan.suse.de>
References: <20081017050120.GA28605@wotan.suse.de>
Message-Id: <20081017142346.FAA6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Oct 2008 14:41:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

> Is this valid?
> 
> 
> It appears that direct callers of expand_stack may not properly lock the newly
> expanded stack if they don't call make_pages_present (page fault handlers do
> this).

When happend this issue?

I think...

case 1. explit mlock to stack 

   1. mlock to stack
        -> make_pages_present is called via mlock(2).
   2. stack increased
        -> no page fault happened.

case 2. swapout and mlock stack

   1. stack swap out
   2. mlock to stack
        -> the page doesn't swap in at the time.
   3. page fault in the stack
        -> the page swap in
           (no need make_present_page())


So, it seems this patch isn't necessary.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
