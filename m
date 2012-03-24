Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 754506B0102
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 08:53:48 -0400 (EDT)
Message-ID: <1332593574.16159.31.camel@twins>
Subject: Re: [PATCH 10/10] oom: Make find_lock_task_mm() sparse-aware
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Sat, 24 Mar 2012 13:52:54 +0100
In-Reply-To: <20120324103127.GJ29067@lizard>
References: <20120324102609.GA28356@lizard> <20120324103127.GJ29067@lizard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

On Sat, 2012-03-24 at 14:31 +0400, Anton Vorontsov wrote:
> This is needed so that callers would not get 'context imbalance'
> warnings from the sparse tool.
>=20
> As a side effect, this patch fixes the following sparse warnings:
>=20
>   CHECK   mm/oom_kill.c
>   mm/oom_kill.c:201:28: warning: context imbalance in 'oom_badness' -
>   unexpected unlock
>   include/linux/rcupdate.h:249:30: warning: context imbalance in
>   'dump_tasks' - unexpected unlock
>   mm/oom_kill.c:453:9: warning: context imbalance in 'oom_kill_task' -
>   unexpected unlock
>   CHECK   mm/memcontrol.c
>   ...
>   mm/memcontrol.c:1130:17: warning: context imbalance in
>   'task_in_mem_cgroup' - unexpected unlock
>=20
> p.s. I know Peter Zijlstra detest the __cond_lock() stuff, but untill
>      we have anything better in sparse, let's use it. This particular
>      patch helped me to detect one bug that I myself made during
>      task->mm fixup series. So, it is useful.

Yeah, so Nacked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Also, why didn't lockdep catch it?

Fix sparse already instead of smearing ugly all over.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
