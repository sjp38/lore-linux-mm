Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8B5856B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 13:35:24 -0400 (EDT)
Received: by lbbgp10 with SMTP id gp10so3245157lbb.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 10:35:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F86B9BE.8000105@jp.fujitsu.com>
References: <4F86B9BE.8000105@jp.fujitsu.com>
Date: Tue, 17 Apr 2012 10:35:22 -0700
Message-ID: <CALWz4izGo4aCyC7xbWyL+yfNiaUmZXPwD8bLgJVpqtcAGfyJ9w@mail.gmail.com>
Subject: Re: [PATCH v1 0/7] memcg remove pre_destroy
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Apr 12, 2012 at 4:17 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> In recent discussion, Tejun Heo, cgroup maintainer, has a plan to remove
> ->pre_destroy(). And now, in cgroup tree, pre_destroy() failure cause WAR=
NING.
>
> By pre_destroy(), rmdir of cgroup can return -EBUSY or some error.
> It makes cgroup complicated and unstable. I said O.K. to remove it and
> this patch is modification for memcg.
>
> One of problem in current implementation is that memcg moves all charges =
to
> parent in pre_destroy(). At doing so, if use_hierarchy=3D0, pre_destroy()=
 may
> hit parent's limit and may return -EBUSY. To fix this problem, this patch
> changes behavior of rmdir() as
>
> =A0- if use_hierarchy=3D0, all remaining charges will go to root cgroup.
> =A0- if use_hierarchy=3D1, all remaining charges will go to the parent.


We need to update the "4.3 Removing a cgroup" session in Documentation.

--Ying

> By this, rmdir failure will not be caused by parent's limitation. And
> I think this meets meaning of use_hierarchy.
>
> This series does
> =A0- add above change of behavior
> =A0- use workqueue to move all pages to parent
> =A0- remove unnecessary codes.
>
> I'm sorry if my reply is delayed, I'm not sure I can have enough time in
> this weekend. Any comments are welcomed.
>
> Thanks,
> -Kame
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
