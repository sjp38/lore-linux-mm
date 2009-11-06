Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 90C4E6B0062
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 10:19:32 -0500 (EST)
Received: by pzk34 with SMTP id 34so748498pzk.11
        for <linux-mm@kvack.org>; Fri, 06 Nov 2009 07:19:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091106134030.a94665d1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262360911050711k47a63896xe4915157664cb822@mail.gmail.com>
	 <20091106084806.7503b165.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091106134030.a94665d1.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 7 Nov 2009 00:19:30 +0900
Message-ID: <28c262360911060719y45f4b58ex2f13853f0d142656@mail.gmail.com>
Subject: Re: [PATCH] show per-process swap usage via procfs v2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, cl@linux-foundation.org, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 6, 2009 at 1:40 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Now, anon_rss and file_rss is counted as RSS and exported via /proc.
> RSS usage is important information but one more information which
> is often asked by users is "usage of swap".(user support team said.)
>
> This patch counts swap entry usage per process and show it via
> /proc/<pid>/status. I think status file is robust against new entry.
> Then, it is the first candidate..
>
> =A0After this, /proc/<pid>/status includes following line
> =A0<snip>
> =A0VmPeak: =A0 315360 kB
> =A0VmSize: =A0 315360 kB
> =A0VmLck: =A0 =A0 =A0 =A0 0 kB
> =A0VmHWM: =A0 =A0180452 kB
> =A0VmRSS: =A0 =A0180452 kB
> =A0VmData: =A0 311624 kB
> =A0VmStk: =A0 =A0 =A0 =A084 kB
> =A0VmExe: =A0 =A0 =A0 =A0 4 kB
> =A0VmLib: =A0 =A0 =A01568 kB
> =A0VmPTE: =A0 =A0 =A0 640 kB
> =A0VmSwap: =A0 131240 kB <=3D=3D=3D new information
>
> Note:
> =A0Because this patch catches swap_pte on page table, this will
> =A0not catch shmem's swapout. It's already accounted in per-shmem
> =A0inode and we don't need to do more.
>
> Changelog: 2009/11/06
> =A0- fixed bad use of is_migration_entry. Now, non_swap_entry() is used.
> Changelog: 2009/11/03
> =A0- clean up.
> =A0- fixed initialization bug at fork (init_mm())
>
> Acked-by: Acked-by; David Rientjes <rientjes@google.com>
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
