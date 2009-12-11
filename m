Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 673EC6B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 20:07:28 -0500 (EST)
Received: by pwi1 with SMTP id 1so335061pwi.6
        for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:07:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091210165911.97850977.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091210165911.97850977.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 11 Dec 2009 10:07:26 +0900
Message-ID: <28c262360912101707i314972d7nf540b27595b8883d@mail.gmail.com>
Subject: Re: [RFC mm][PATCH 3/5] counting swap ents per mm
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Thu, Dec 10, 2009 at 4:59 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> One of frequent questions from users about memory management is
> what numbers of swap ents are user for processes. And this information wi=
ll
> give some hints to oom-killer.
>
> Besides we can count the number of swapents per a process by scanning
> /proc/<pid>/smaps, this is very slow and not good for usual process infor=
mation
> handler which works like 'ps' or 'top'.
> (ps or top is now enough slow..)
>
> This patch adds a counter of swapents to mm_counter and update is at
> each swap events. Information is exported via /proc/<pid>/status file as
>
> [kamezawa@bluextal ~]$ cat /proc/self/status
> Name: =C2=A0 cat
> State: =C2=A0R (running)
> Tgid: =C2=A0 2904
> Pid: =C2=A0 =C2=A02904
> PPid: =C2=A0 2862
> TracerPid: =C2=A0 =C2=A0 =C2=A00
> Uid: =C2=A0 =C2=A0500 =C2=A0 =C2=A0 500 =C2=A0 =C2=A0 500 =C2=A0 =C2=A0 5=
00
> Gid: =C2=A0 =C2=A0500 =C2=A0 =C2=A0 500 =C2=A0 =C2=A0 500 =C2=A0 =C2=A0 5=
00
> FDSize: 256
> Groups: 500
> VmPeak: =C2=A0 =C2=A082696 kB
> VmSize: =C2=A0 =C2=A082696 kB
> VmLck: =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB
> VmHWM: =C2=A0 =C2=A0 =C2=A0 504 kB
> VmRSS: =C2=A0 =C2=A0 =C2=A0 504 kB
> VmData: =C2=A0 =C2=A0 =C2=A0172 kB
> VmStk: =C2=A0 =C2=A0 =C2=A0 =C2=A084 kB
> VmExe: =C2=A0 =C2=A0 =C2=A0 =C2=A048 kB
> VmLib: =C2=A0 =C2=A0 =C2=A01568 kB
> VmPTE: =C2=A0 =C2=A0 =C2=A0 =C2=A040 kB
> VmSwap: =C2=A0 =C2=A0 =C2=A0 =C2=A00 kB <=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D this.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
