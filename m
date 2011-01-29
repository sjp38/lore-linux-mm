Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D23EE8D0039
	for <linux-mm@kvack.org>; Sat, 29 Jan 2011 07:47:58 -0500 (EST)
Received: by pzk27 with SMTP id 27so735192pzk.14
        for <linux-mm@kvack.org>; Sat, 29 Jan 2011 04:47:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 29 Jan 2011 18:17:56 +0530
Message-ID: <AANLkTiktzgxEVROyB=-0ZNq5xzao1Q-Cu3xpGqhx0gxm@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH 0/4] Fixes for memcg with THP
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 8:52 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> On recent -mm, when I run make -j 8 under 200M limit of memcg, as
> ==
> # mount -t cgroup none /cgroup/memory -o memory
> # mkdir /cgroup/memory/A
> # echo 200M > /cgroup/memory/A/memory.limit_in_bytes
> # echo $$ > /cgroup/memory/A/tasks
> # make -j 8 kernel
> ==
>
> I see hangs with khugepaged. That's because memcg's memory reclaim
> routine doesn't handle HUGE_PAGE request in proper way. And khugepaged
> doesn't know about memcg.
>
> This patch set is for fixing above hang. Patch 1-3 seems obvious and
> has the same concept as patches in RHEL.

Do you have any backtraces? Are they in the specific patches?

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
