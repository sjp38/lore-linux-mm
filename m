Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 044C06B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 09:41:52 -0500 (EST)
Received: by iwn5 with SMTP id 5so32650iwn.11
        for <linux-mm@kvack.org>; Thu, 05 Nov 2009 06:41:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 5 Nov 2009 23:41:50 +0900
Message-ID: <2f11576a0911050641j8799c5kbd390116edcc566d@mail.gmail.com>
Subject: Re: [PATCH] show per-process swap usage via procfs
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

2009/11/4 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>
> Passed several tests and one bug was fixed since RFC version.
> This patch is against mmotm.
> =3D
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

Sidenote: top(1) can show SWAP usage. but it is crazy buggy
implementation. it define
VIRT =3D SWAP + RES (see man top or actual source code). this patch help
to fix its insane
calculation.

    Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
