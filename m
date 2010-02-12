Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0B7DF6B0078
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 21:39:37 -0500 (EST)
Received: by pzk8 with SMTP id 8so370025pzk.22
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 18:39:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100212105318.caf37133.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100212105318.caf37133.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 12 Feb 2010 11:39:35 +0900
Message-ID: <28c262361002111839t291b8ac2xdb9b89b354a115e0@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killing a child process in an
	other cgroup
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, stable@kernel.org, rientjes@google.com, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 12, 2010 at 10:53 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This patch itself is againt mmotm-Feb10 but can be applied to 2.6.32.8
> without problem.
>
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Now, oom-killer is memcg aware and it finds the worst process from
> processes under memcg(s) in oom. Then, it kills victim's child at first.
> It may kill a child in other cgroup and may not be any help for recovery.
> And it will break the assumption users have...
>
> This patch fixes it.
>
> CC: stable@kernel.org
> CC: Minchan Kim <minchan.kim@gmail.com>
> CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Sorry for noise, Kame.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
