Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EEDE16001DA
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 21:49:21 -0500 (EST)
Received: by pzk7 with SMTP id 7so249804pzk.12
        for <linux-mm@kvack.org>; Fri, 12 Feb 2010 18:49:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1002100228240.8001@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1002100228240.8001@chino.kir.corp.google.com>
Date: Sat, 13 Feb 2010 11:49:20 +0900
Message-ID: <28c262361002121849s68754559gf1e6f1b64cbd083f@mail.gmail.com>
Subject: Re: [patch 2/7 -mm] oom: sacrifice child with highest badness score
	for parent
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 11, 2010 at 1:32 AM, David Rientjes <rientjes@google.com> wrote=
:
> When a task is chosen for oom kill, the oom killer first attempts to
> sacrifice a child not sharing its parent's memory instead.
> Unfortunately, this often kills in a seemingly random fashion based on
> the ordering of the selected task's child list. =C2=A0Additionally, it is=
 not
> guaranteed at all to free a large amount of memory that we need to
> prevent additional oom killing in the very near future.
>
> Instead, we now only attempt to sacrifice the worst child not sharing its
> parent's memory, if one exists. =C2=A0The worst child is indicated with t=
he
> highest badness() score. =C2=A0This serves two advantages: we kill a
> memory-hogging task more often, and we allow the configurable
> /proc/pid/oom_adj value to be considered as a factor in which child to
> kill.
>
> Reviewers may observe that the previous implementation would iterate
> through the children and attempt to kill each until one was successful
> and then the parent if none were found while the new code simply kills
> the most memory-hogging task or the parent. =C2=A0Note that the only time
> oom_kill_task() fails, however, is when a child does not have an mm or
> has a /proc/pid/oom_adj of OOM_DISABLE. =C2=A0badness() returns 0 for bot=
h
> cases, so the final oom_kill_task() will always succeed.
>
> Signed-off-by: David Rientjes <rientjes@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Regardless of forkbom detection, It does makes sense to me.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
