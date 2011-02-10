Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 248F28D003B
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 21:49:25 -0500 (EST)
Received: by iyi20 with SMTP id 20so867567iyi.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 18:49:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110209162324.ea7e2e52.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110209162324.ea7e2e52.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 10 Feb 2011 11:49:19 +0900
Message-ID: <AANLkTimSvFNMLwNtHJePzz0qh4My-CJ4YDcrGFH7eBS6@mail.gmail.com>
Subject: Re: [PATCH][BUGFIX] memcg: fix leak of accounting at failure path of
 hugepage collapsing.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Wed, Feb 9, 2011 at 4:23 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> There was a big bug. Anyway, thank you for adding new bad_page for memcg.
> =3D=3D
>
> mem_cgroup_uncharge_page() should be called in all failure case
> after mem_cgroup_charge_newpage() is called in
> huge_memory.c::collapse_huge_page()
>
> =C2=A0[ 4209.076861] BUG: Bad page state in process khugepaged =C2=A0pfn:=
1e9800
> =C2=A0[ 4209.077601] page:ffffea0006b14000 count:0 mapcount:0 mapping: =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(null) index:0x2800
> =C2=A0[ 4209.078674] page flags: 0x40000000004000(head)
> =C2=A0[ 4209.079294] pc:ffff880214a30000 pc->flags:2146246697418756 pc->m=
em_cgroup:ffffc9000177a000
> =C2=A0[ 4209.082177] (/A)
> =C2=A0[ 4209.082500] Pid: 31, comm: khugepaged Not tainted 2.6.38-rc3-mm1=
 #1
> =C2=A0[ 4209.083412] Call Trace:
> =C2=A0[ 4209.083678] =C2=A0[<ffffffff810f4454>] ? bad_page+0xe4/0x140
> =C2=A0[ 4209.084240] =C2=A0[<ffffffff810f53e6>] ? free_pages_prepare+0xd6=
/0x120
> =C2=A0[ 4209.084837] =C2=A0[<ffffffff8155621d>] ? rwsem_down_failed_commo=
n+0xbd/0x150
> =C2=A0[ 4209.085509] =C2=A0[<ffffffff810f5462>] ? __free_pages_ok+0x32/0x=
e0
> =C2=A0[ 4209.086110] =C2=A0[<ffffffff810f552b>] ? free_compound_page+0x1b=
/0x20
> =C2=A0[ 4209.086699] =C2=A0[<ffffffff810fad6c>] ? __put_compound_page+0x1=
c/0x30
> =C2=A0[ 4209.087333] =C2=A0[<ffffffff810fae1d>] ? put_compound_page+0x4d/=
0x200
> =C2=A0[ 4209.087935] =C2=A0[<ffffffff810fb015>] ? put_page+0x45/0x50
> =C2=A0[ 4209.097361] =C2=A0[<ffffffff8113f779>] ? khugepaged+0x9e9/0x1430
> =C2=A0[ 4209.098364] =C2=A0[<ffffffff8107c870>] ? autoremove_wake_functio=
n+0x0/0x40
> =C2=A0[ 4209.099121] =C2=A0[<ffffffff8113ed90>] ? khugepaged+0x0/0x1430
> =C2=A0[ 4209.099780] =C2=A0[<ffffffff8107c236>] ? kthread+0x96/0xa0
> =C2=A0[ 4209.100452] =C2=A0[<ffffffff8100dda4>] ? kernel_thread_helper+0x=
4/0x10
> =C2=A0[ 4209.101214] =C2=A0[<ffffffff8107c1a0>] ? kthread+0x0/0xa0
> =C2=A0[ 4209.101842] =C2=A0[<ffffffff8100dda0>] ? kernel_thread_helper+0x=
0/0x10
>
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
