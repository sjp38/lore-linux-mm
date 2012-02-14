Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id BD6536B13F3
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 02:22:05 -0500 (EST)
Received: by mail-vw0-f41.google.com with SMTP id p1so5286971vbi.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 23:22:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120214121314.6216e0aa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com> <20120214121314.6216e0aa.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 13 Feb 2012 23:21:45 -0800
Message-ID: <CAHH2K0a051EnNQbtsx9ztTbcHxKGu8u1tQD60w06aQwUA0nyAw@mail.gmail.com>
Subject: Re: [PATCH 3/6 v4] memcg: remove PCG_MOVE_LOCK flag from page_cgroup.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>

On Mon, Feb 13, 2012 at 7:13 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From ffd1b013fe294a80c12e3f30e85386135a6fb284 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 2 Feb 2012 11:49:59 +0900
> Subject: [PATCH 3/6] memcg: remove PCG_MOVE_LOCK flag from page_cgroup.
>
> PCG_MOVE_LOCK is used for bit spinlock to avoid race between overwriting
> pc->mem_cgroup and page statistics accounting per memcg.
> This lock helps to avoid the race but the race is very rare because movin=
g
> tasks between cgroup is not a usual job.
> So, it seems using 1bit per page is too costly.
>
> This patch changes this lock as per-memcg spinlock and removes PCG_MOVE_L=
OCK.
>
> If smaller lock is required, we'll be able to add some hashes but
> I'd like to start from this.
>
> Changelog:
> =A0- fixed to pass memcg as an argument rather than page_cgroup.
> =A0 =A0and renamed from move_lock_page_cgroup() to move_lock_mem_cgroup()
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Seems good.  Thanks.

Acked-by: Greg Thelen <gthelen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
