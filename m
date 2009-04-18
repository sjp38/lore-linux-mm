Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 05E3A5F0001
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 02:42:54 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3I6hX7Y015474
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 18 Apr 2009 15:43:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BDF1445DE52
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:43:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9976145DE4E
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:43:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A8ED1DB803C
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:43:33 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 31A7F1DB8037
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:43:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: AIM9 from 2.6.22 to 2.6.29
In-Reply-To: <alpine.DEB.1.10.0904161616001.17864@qirst.com>
References: <alpine.DEB.1.10.0904161616001.17864@qirst.com>
Message-Id: <20090418154207.1260.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat, 18 Apr 2009 15:43:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Here is a list of AIM9 results for all kernels between 2.6.22 2.6.29:
> 
> Significant regressions:
> 
> creat-clo
> page_test

I'm interest to it.
How do I get AIM9 benchmark?

and, Can you compare CONFIG_UNEVICTABLE_LRU is y and n?


> brk_test
> exec_test
> fork_test (!!)
> shell_*
> fifo_test
> pipe_cpy
> 
> Significant improvements:
> 
> signal_test
> tcp_test
> udp_test


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
