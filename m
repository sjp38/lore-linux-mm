Received: from m1.gw.fujitsu.co.jp ([10.0.50.71]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i9J4OiqK009876 for <linux-mm@kvack.org>; Tue, 19 Oct 2004 13:24:44 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i9J4OhND007049 for <linux-mm@kvack.org>; Tue, 19 Oct 2004 13:24:43 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp (s3 [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7735343F20
	for <linux-mm@kvack.org>; Tue, 19 Oct 2004 13:24:43 +0900 (JST)
Received: from fjmail503.fjmail.jp.fujitsu.com (fjmail503-0.fjmail.jp.fujitsu.com [10.59.80.100])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D63C43F23
	for <linux-mm@kvack.org>; Tue, 19 Oct 2004 13:24:43 +0900 (JST)
Received: from [10.124.100.187]
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120])
 by fjmail503.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I5T00CJEDL4N1@fjmail503.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Tue, 19 Oct 2004 13:24:41 +0900 (JST)
Date: Tue, 19 Oct 2004 13:30:24 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] CONFIG_NONLINEAR for small systems
In-reply-to: <4173D219.3010706@shadowen.org>
Message-id: <41749860.9070503@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <4173D219.3010706@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
Andy Whitcroft wrote:

> The generalised CONFIG_NONLINEAR memory model described at OLS
> seemed provide more than enough decriptive power to address this
> issue but provided far more functionality that was required.
> Particularly it breaks the identity V=P+c to allow compression of
> the kernel address space, which is not required on these smaller systems.
> 
We have *future* issue to hotplug kernel memory and kernel's virtual address renaming
will be used for it.
As you say, if kernel memory is not remaped,  keeping V=P+c looks good.
But our current direction is to enable kernel-memory-hotplug, which
needs kernel's virtual memory renaming, I think.

NONLINEAR_OPTIMISED looks a bit complicated.
Can replace them with some other name ? Hmm...NONLINEAR_NOREMAP ?


> This patch set is implemented as a proof-of-concept to show
> that a simplified CONFIG_NONLINEAR based implementation could provide
> sufficient flexibility to solve the problems for these systems.
> 
Very interesting. But I'm not sure whether we can use more page->flags bit :[.
I recommend you not to use more page->flags bits.


Kame <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
