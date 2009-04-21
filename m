Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 67E1C6B004D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 04:30:49 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L8VGDm012392
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Apr 2009 17:31:16 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E94D245DD76
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 17:31:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C2CEA45DD74
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 17:31:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6273CE08003
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 17:31:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B0661DB801E
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 17:31:14 +0900 (JST)
Date: Tue, 21 Apr 2009 17:29:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2009-04-17-15-19 uploaded
Message-Id: <20090421172939.803fcd1e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200904172238.n3HMc2RA018806@imap1.linux-foundation.org>
References: <200904172238.n3HMc2RA018806@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Apr 2009 15:19:22 -0700
akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2009-04-17-15-19 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
> 
>    git://git.zen-sources.org/zen/mmotm.git
> 
> It contains the following patches against 2.6.30-rc2:
> 
Can I make a question ?

It seems SLQB is a default slab allocator in this mmotm.
Which is the reason ? "do more test!" or "it's better in general!!!"

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
