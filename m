Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BCC558D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 19:21:15 -0400 (EDT)
Received: by iyf13 with SMTP id 13so10917685iyf.14
        for <linux-mm@kvack.org>; Tue, 22 Mar 2011 16:21:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110322200759.B067.A69D9226@jp.fujitsu.com>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com>
	<20110322194721.B05E.A69D9226@jp.fujitsu.com>
	<20110322200759.B067.A69D9226@jp.fujitsu.com>
Date: Wed, 23 Mar 2011 08:21:12 +0900
Message-ID: <AANLkTikN835dfU9xozTWbOh6cjSEG0XgU_Ayn+dRqDug@mail.gmail.com>
Subject: Re: [PATCH 3/5] oom: create oom autogroup
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mike Galbraith <efault@gmx.de>

On Tue, Mar 22, 2011 at 8:08 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> When plenty processes (eg fork bomb) are running, the TIF_MEMDIE task
> never exit, at least, human feel it's never. therefore kernel become
> hang-up.
>
> "perf sched" tell us a hint.
>
> =C2=A0-------------------------------------------------------------------=
-----------
> =C2=A0Task =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
| =C2=A0 Runtime ms =C2=A0| Average delay ms | Maximum delay ms |
> =C2=A0-------------------------------------------------------------------=
-----------
> =C2=A0python:1754 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0 =C2=
=A00.197 ms | avg: 1731.727 ms | max: 3433.805 ms |
> =C2=A0python:1843 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0 =C2=
=A00.489 ms | avg: 1707.433 ms | max: 3622.955 ms |
> =C2=A0python:1715 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0 =C2=
=A00.220 ms | avg: 1707.125 ms | max: 3623.246 ms |
> =C2=A0python:1818 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0 =C2=
=A02.127 ms | avg: 1527.331 ms | max: 3622.553 ms |
> =C2=A0...
> =C2=A0...
>
> Processes flood makes crazy scheduler delay. and then the victim process
> can't run enough. Grr. Should we do?
>
> Fortunately, we already have anti process flood framework, autogroup!
> This patch reuse this framework and avoid kernel live lock.

That's cool idea but I have a concern.

You remove boosting priority in [2/5] and move victim tasks into autogroup.
If I understand autogroup right, victim process and threads in the
process take less schedule chance than now.

Could it make unnecessary killing of other tasks?
I am not sure. Just out of curiosity.

Thanks for nice work, Kosaki.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
