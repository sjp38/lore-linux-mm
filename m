Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C2CAB6B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 09:01:29 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1846089bwz.14
        for <linux-mm@kvack.org>; Thu, 16 Jun 2011 06:01:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110616100937.GA12317@elte.hu>
References: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
	<20110613120608.d5243bc9.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616100937.GA12317@elte.hu>
Date: Thu, 16 Jun 2011 22:01:25 +0900
Message-ID: <BANLkTik8oETUSphYDfP8g8CgyHnDcaBXOg@mail.gmail.com>
Subject: Re: [-git build bug, PATCH] Re: [BUGFIX][PATCH 2/5] memcg: fix
 init_page_cgroup nid with sparsemem
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>

2011/6/16 Ingo Molnar <mingo@elte.hu>:
>
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> Date: Mon, 13 Jun 2011 10:09:17 +0900
>> Subject: [PATCH 2/5] [BUGFIX] memcg: fix init_page_cgroup nid with spars=
emem
>
> This fresh upstream commit commit:
>
> =A037573e8c7182: memcg: fix init_page_cgroup nid with sparsemem
>
> is causing widespread build failures on latest -git, on x86:
>
> =A0mm/page_cgroup.c:308:3: error: implicit declaration of function =91nod=
e_start_pfn=92 [-Werror=3Dimplicit-function-declaration]
> =A0mm/page_cgroup.c:309:3: error: implicit declaration of function =91nod=
e_end_pfn=92 [-Werror=3Dimplicit-function-declaration]
>
> On any config that has CONFIG_CGROUP_MEM_RES_CTLR=3Dy enabled but
> CONFIG_NUMA disabled.
>
> For now i've worked it around with the patch below, but the real
> solution would be to make the page_cgroup.c code not depend on NUMA.
>
> Thanks,
>
> =A0 =A0 =A0 =A0Ingo
>
yes, very sorry. I'm now preparing a fix in this thread.

http://marc.info/?t=3D130819986800002&r=3D1&w=3D2

I think I'll be able to post a final fix, tomorrow. I'll cc you when I'll p=
ost.
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
