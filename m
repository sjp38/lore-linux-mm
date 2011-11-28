Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0A06B002D
	for <linux-mm@kvack.org>; Sun, 27 Nov 2011 21:18:55 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3E8F43EE0BC
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 11:18:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 27A2945DE70
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 11:18:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D5B645DE6B
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 11:18:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id ECDB21DB8040
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 11:18:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id ADC761DB8041
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 11:18:52 +0900 (JST)
Date: Mon, 28 Nov 2011 11:17:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: linux-2.6.35.13: Schedule while atomic bug and kernel crash in
 kswapd.
Message-Id: <20111128111744.3020ad4d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAFPAmTQCcWf0yLm239b_fQTv9CY9t=B5gUrDO1wKM97pyrJurQ@mail.gmail.com>
References: <CAFPAmTQCcWf0yLm239b_fQTv9CY9t=B5gUrDO1wKM97pyrJurQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 25 Nov 2011 18:20:31 +0530
Kautuk Consul <consul.kautuk@gmail.com> wrote:

> Hi,
> 
> I am running linux-2.6.35.31 on my ARM system and I got around 197
> schedule while atomics and then finally a kernel crash.
> 
> Can anyone suggest some MMpatches to apply on this fix this problem ?
> 
> I got the following schedule while atomic log around 197 times:
> ------------------------------------------------------------------------------------------
> Backtrace(CPU 0):
> [<c00393a0>] (dump_backtrace+0x0/0x11c) from [<c0393728>] (dump_stack+0x20/0x24)
> [<c0393708>] (dump_stack+0x0/0x24) from [<c0058ad0>] (__schedule_bug+0x70/0x7c)
> [<c0058a60>] (__schedule_bug+0x0/0x7c) from [<c03939f8>] (schedule+0x74/0x5a4)
>   r5:d2002000 r4:d1f79440
>  [<c0393984>] (schedule+0x0/0x5a4) from [<c03948a0>]
> (schedule_timeout+0x2c8/0x304)
>  [<c03945d8>] (schedule_timeout+0x0/0x304) from [<c0393958>]
> (io_schedule_timeout+0x50/0x7c)
>   r7:d1f79440 r6:d2002000 r5:c04c0088 r4:c04bfc88
>  [<c0393908>] (io_schedule_timeout+0x0/0x7c) from [<c0109cbc>]
> (congestion_wait+0x7c/0xa0)
>   r6:00000019 r5:c04c6230 r4:d2003edc r3:00000000
>  [<c0109c40>] (congestion_wait+0x0/0xa0) from [<c0102268>] (kswapd+0x594/0x61c)
>   r7:00000000 r6:c04d7a28 r5:00000008 r4:c04d76f4
>  [<c0101cd4>] (kswapd+0x0/0x61c) from [<c007db6c>] (kthread+0x90/0x98)
>  [<c007dadc>] (kthread+0x0/0x98) from [<c00642f4>] (do_exit+0x0/0x708)
>   r7:00000013 r6:c00642f4 r5:c007dadc r4:d1f47f3c
>  BUG: scheduling while atomic: kswapd0/16/0x00000000
> 

Hmm, it seems strange and I never see this.
This seems __schedule_bug() is called but preempt_count() is 0x00000000.
Could you show your .config ?

Regards,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
