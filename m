Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 05D206B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 21:11:13 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o681BBIb007620
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 8 Jul 2010 10:11:12 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9849E45DE56
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 10:11:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7777145DE52
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 10:11:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DA661DB8061
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 10:11:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 035151DB805E
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 10:11:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: FYI: mmap_sem OOM patch
In-Reply-To: <20100708084005.CD0F.A69D9226@jp.fujitsu.com>
References: <20100707231134.GA26555@google.com> <20100708084005.CD0F.A69D9226@jp.fujitsu.com>
Message-Id: <20100708100836.CD1A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  8 Jul 2010 10:11:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>
List-ID: <linux-mm.kvack.org>

> Yup.
> If admins want to kill memory hogging process manually when the system
> is under heavy swap thrashing, we will face the same problem, need 
> unfairness and fast exit. So, unfair exiting design looks very good.
> 
> If you will updated the description, I'm glad :)

I have one more topic. can we check fatal_signal_pending() instead TIF_MEMDIE?
As I said, if the process received SIGKILL, do the fork/exec/brk/mmap 
starvations have any problem?

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
