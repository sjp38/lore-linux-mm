Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CF55B8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 01:29:44 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p3L5TerL008667
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 22:29:41 -0700
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by kpbe11.cbf.corp.google.com with ESMTP id p3L5Tdc5015791
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 22:29:39 -0700
Received: by qwj9 with SMTP id 9so886836qwj.7
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 22:29:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110421125005.eb2be43c.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421125005.eb2be43c.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 20 Apr 2011 22:29:38 -0700
Message-ID: <BANLkTi=A39ro_Pc-OuqpiTpCo8ZENmCprw@mail.gmail.com>
Subject: Re: [PATCH 3/3/] fix mem_cgroup_watemark_ok (Was Re: [PATCH V6 00/10]
 memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bc0de94a04a1670760
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0ce008bc0de94a04a1670760
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 20, 2011 at 8:50 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> Ying, I noticed this at test. please fix the code in your set.
> ==
> if low_wmark_distance = 0, mem_cgroup_watermark_ok() returns
> false when usage hits limit.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    3 +++
>  1 file changed, 3 insertions(+)
>
> Index: mmotm-Apr14/mm/memcontrol.c
> ===================================================================
> --- mmotm-Apr14.orig/mm/memcontrol.c
> +++ mmotm-Apr14/mm/memcontrol.c
> @@ -5062,6 +5062,9 @@ int mem_cgroup_watermark_ok(struct mem_c
>        long ret = 0;
>        int flags = CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH;
>
> +       if (!mem->low_wmark_distance)
> +               return 1;
> +
>        VM_BUG_ON((charge_flags & flags) == flags);
>
>        if (charge_flags & CHARGE_WMARK_LOW)
>
> Thanks. Will add this in the next post.

--Ying

--000e0ce008bc0de94a04a1670760
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 20, 2011 at 8:50 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<br>
Ying, I noticed this at test. please fix the code in your set.<br>
=3D=3D<br>
if low_wmark_distance =3D 0, mem_cgroup_watermark_ok() returns<br>
false when usage hits limit.<br>
<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0mm/memcontrol.c | =A0 =A03 +++<br>
=A01 file changed, 3 insertions(+)<br>
<br>
Index: mmotm-Apr14/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-Apr14.orig/mm/memcontrol.c<br>
+++ mmotm-Apr14/mm/memcontrol.c<br>
@@ -5062,6 +5062,9 @@ int mem_cgroup_watermark_ok(struct mem_c<br>
 =A0 =A0 =A0 =A0long ret =3D 0;<br>
 =A0 =A0 =A0 =A0int flags =3D CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH;<br>
<br>
+ =A0 =A0 =A0 if (!mem-&gt;low_wmark_distance)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;<br>
+<br>
 =A0 =A0 =A0 =A0VM_BUG_ON((charge_flags &amp; flags) =3D=3D flags);<br>
<br>
 =A0 =A0 =A0 =A0if (charge_flags &amp; CHARGE_WMARK_LOW)<br>
<br></blockquote><div>Thanks. Will add this in the next post.</div><div><br=
></div><div>--Ying=A0</div></div><br>

--000e0ce008bc0de94a04a1670760--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
