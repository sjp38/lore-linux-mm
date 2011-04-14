Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9D96D900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 21:09:20 -0400 (EDT)
Received: by vws4 with SMTP id 4so1444228vws.14
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:09:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1104131740280.16515@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104131132240.5563@chino.kir.corp.google.com>
	<20110414090310.07FF.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1104131740280.16515@chino.kir.corp.google.com>
Date: Thu, 14 Apr 2011 10:09:17 +0900
Message-ID: <BANLkTikx12d+vBpc6esRDYSaFr1dH+9HMA@mail.gmail.com>
Subject: Re: [patch v2] oom: replace PF_OOM_ORIGIN with toggling oom_score_adj
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, Apr 14, 2011 at 9:41 AM, David Rientjes <rientjes@google.com> wrote=
:
> There's a kernel-wide shortage of per-process flags, so it's always
> helpful to trim one when possible without incurring a significant
> penalty. =C2=A0It's even more important when you're planning on adding a =
per-
> process flag yourself, which I plan to do shortly for transparent
> hugepages.
>
> PF_OOM_ORIGIN is used by ksm and swapoff to prefer current since it has a
> tendency to allocate large amounts of memory and should be preferred for
> killing over other tasks. =C2=A0We'd rather immediately kill the task mak=
ing
> the errant syscall rather than penalizing an innocent task.
>
> This patch removes PF_OOM_ORIGIN since its behavior is equivalent to
> setting the process's oom_score_adj to OOM_SCORE_ADJ_MAX.
>
> The process's old oom_score_adj is stored and then set to
> OOM_SCORE_ADJ_MAX during the time it used to have PF_OOM_ORIGIN. =C2=A0Th=
e old
> value is then reinstated when the process should no longer be considered
> a high priority for oom killing.
>
> Signed-off-by: David Rientjes <rientjes@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Seem to be reasonable and code don't have a problem.
But couldn't we make the function in general(ex, passed task_struct)
and use it when we change oom_score_adj(ex, oom_score_adj_write)?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
