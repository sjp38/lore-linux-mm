Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BEFDE900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 21:21:58 -0400 (EDT)
Received: by vws4 with SMTP id 4so1453832vws.14
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:21:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1104131811470.19388@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104131132240.5563@chino.kir.corp.google.com>
	<20110414090310.07FF.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1104131740280.16515@chino.kir.corp.google.com>
	<BANLkTikx12d+vBpc6esRDYSaFr1dH+9HMA@mail.gmail.com>
	<alpine.DEB.2.00.1104131811470.19388@chino.kir.corp.google.com>
Date: Thu, 14 Apr 2011 10:21:56 +0900
Message-ID: <BANLkTi=EVZJVdYSx7LitP__gPH4PBEJy6w@mail.gmail.com>
Subject: Re: [patch v2] oom: replace PF_OOM_ORIGIN with toggling oom_score_adj
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, Apr 14, 2011 at 10:12 AM, David Rientjes <rientjes@google.com> wrot=
e:
> On Thu, 14 Apr 2011, Minchan Kim wrote:
>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>>
>
> Thanks!
>
>> Seem to be reasonable and code don't have a problem.
>> But couldn't we make the function in general(ex, passed task_struct)
>> and use it when we change oom_score_adj(ex, oom_score_adj_write)?
>>
>
> I thought about doing that, but oom_score_adj_write doesn't operate on
> current, so it needs to lock p->sighand differently and also does a test
> to ensure that the new value is only less than the current value for
> CAP_SYS_RESOURCE. =C2=A0That test is required to take place under the loc=
k as
> well.
>

Yes. We already have facilities for it(ex, task_lock, lock_task_sighand).
And I think CAP_SYS_RESOURCE check in general function don't have a problem=
.

Of course, it adds unnecessary overhead slightly but it's not a hot
path.  What's problem for you to go ahead?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
