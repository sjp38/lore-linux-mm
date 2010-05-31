Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6EE156B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 01:06:49 -0400 (EDT)
Received: by gwb19 with SMTP id 19so2635918gwb.14
        for <linux-mm@kvack.org>; Sun, 30 May 2010 22:06:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100529125136.62CA.A69D9226@jp.fujitsu.com>
References: <20100528154549.GC12035@barrios-desktop>
	<20100528164826.GJ11364@uudg.org>
	<20100529125136.62CA.A69D9226@jp.fujitsu.com>
Date: Mon, 31 May 2010 14:06:48 +0900
Message-ID: <AANLkTimg3PuUAmUUib2pdXNyEeniccLSCEvAm9jtKNji@mail.gmail.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

Hi, Kosaki.

On Sat, May 29, 2010 at 12:59 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>> oom-killer: give the dying task rt priority (v3)
>>
>> Give the dying task RT priority so that it can be scheduled quickly and =
die,
>> freeing needed memory.
>>
>> Signed-off-by: Luis Claudio R. Gon=C3=A7alves <lgoncalv@redhat.com>
>
> Almostly acceptable to me. but I have two requests,
>
> - need 1) force_sig() 2)sched_setscheduler() order as Oleg mentioned
> - don't boost priority if it's in mem_cgroup_out_of_memory()

Why do you want to not boost priority if it's path of memcontrol?

If it's path of memcontrol and CONFIG_CGROUP_MEM_RES_CTLR is enabled,
mem_cgroup_out_of_memory will select victim task in memcg.
So __oom_kill_task's target task would be in memcg, I think.

As you and memcg guys don't complain this, I would be missing something.
Could you explain it? :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
