Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DD44B6B01C1
	for <linux-mm@kvack.org>; Fri, 28 May 2010 01:59:07 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4S5x4Cc026092
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 28 May 2010 14:59:04 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0537945DE57
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:59:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7084645DE54
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:59:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 596AAE08001
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:59:03 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E8E951DB803C
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:59:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <AANLkTikB-8Qu03VrA5Z0LMXM_alSV7SLqzl-MmiLmFGv@mail.gmail.com>
References: <20100528143605.7E2A.A69D9226@jp.fujitsu.com> <AANLkTikB-8Qu03VrA5Z0LMXM_alSV7SLqzl-MmiLmFGv@mail.gmail.com>
Message-Id: <20100528145329.7E2D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri, 28 May 2010 14:59:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, balbir@linux.vnet.ibm.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

> RT Task
> 
> void non-RT-function()
> {
>    system call();
>    buffer = malloc();
>    memset(buffer);
> }
> /*
>  * We make sure this function must be executed in some millisecond
>  */
> void RT-function()
> {
>    some calculation(); <- This doesn't have no dynamic characteristic
> }
> int main()
> {
>    non-RT-function();
>    /* This function make sure RT-function cannot preempt by others */
>    set_RT_max_high_priority();
>    RT-function A();
>    set_normal_priority();
>    non-RT-function();
> }
> 
> We don't want realtime in whole function of the task. What we want is
> just RT-function A.
> Of course, current Linux cannot make perfectly sure RT-functionA can
> not preempt by others.
> That's because some interrupt or exception happen. But RT-function A
> doesn't related to any dynamic characteristic. What can justify to
> preempt RT-function A by other processes?

As far as my observation, RT-function always have some syscall. because pure
calculation doesn't need deterministic guarantee. But _if_ you are really
using such priority design. I'm ok maximum NonRT priority instead maximum
RT priority too.

Luis, NonRT high priority break your use case? and if yes, can you please
explain the reason?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
