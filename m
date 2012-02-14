Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id E3B776B13F1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 02:21:34 -0500 (EST)
Received: by vbip1 with SMTP id p1so5286971vbi.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 23:21:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120214120640.ef2ef23a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com> <20120214120640.ef2ef23a.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 13 Feb 2012 23:21:13 -0800
Message-ID: <CAHH2K0a8h5dSWp2-TXW3s2LKnv2d0c6Z9fTBc0UxKdx=H6pSRg@mail.gmail.com>
Subject: Re: [PATCH 1/6 v4] memcg: remove EXPORT_SYMBOL(mem_cgroup_update_page_stat)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>

On Mon, Feb 13, 2012 at 7:06 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> This is just a cleanup.
> =3D=3D
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 2 Feb 2012 12:05:41 +0900
> Subject: [PATCH 1/6] memcg: remove EXPORT_SYMBOL(mem_cgroup_update_page_s=
tat)
>
> From the log, I guess EXPORT was for preparing dirty accounting.
> But _now_, we don't need to export this. Remove this for now.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good to me.

Reviewed-by: Greg Thelen <gthelen@google.com>

> ---
> =A0mm/memcontrol.c | =A0 =A01 -
> =A01 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ab315ab..4c2b759 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1897,7 +1897,6 @@ out:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0move_unlock_page_cgroup(pc, &flags);
> =A0 =A0 =A0 =A0rcu_read_unlock();
> =A0}
> -EXPORT_SYMBOL(mem_cgroup_update_page_stat);
>
> =A0/*
> =A0* size of first charge trial. "32" comes from vmscan.c's magic value.
> --
> 1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
