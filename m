Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA366B0011
	for <linux-mm@kvack.org>; Fri, 13 May 2011 01:25:16 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p4D5PCD6021545
	for <linux-mm@kvack.org>; Thu, 12 May 2011 22:25:12 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by kpbe20.cbf.corp.google.com with ESMTP id p4D5P3Cl028358
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 22:25:11 -0700
Received: by qyk2 with SMTP id 2so170406qyk.0
        for <linux-mm@kvack.org>; Thu, 12 May 2011 22:25:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 12 May 2011 22:25:10 -0700
Message-ID: <BANLkTi=9oKwq-8f-kdinn0pUZ04g5Z7Gnw@mail.gmail.com>
Subject: Re: [PATCH][BUGFIX] memcg fix zone congestion
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa8949ec904a32187bb
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>

--002354470aa8949ec904a32187bb
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 12, 2011 at 8:10 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> ZONE_CONGESTED should be a state of global memory reclaim.
> If not, a busy memcg sets this and give unnecessary throttoling in
> wait_iff_congested() against memory recalim in other contexts. This makes
> system performance bad.
>
> I'll think about "memcg is congested!" flag is required or not, later.
> But this fix is required 1st.
>

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/vmscan.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> Index: mmotm-May11/mm/vmscan.c
> ===================================================================
> --- mmotm-May11.orig/mm/vmscan.c
> +++ mmotm-May11/mm/vmscan.c
> @@ -941,7 +941,8 @@ keep_lumpy:
>         * back off and wait for congestion to clear because further reclaim
>         * will encounter the same problem
>         */
> -       if (nr_dirty == nr_congested && nr_dirty != 0)
> +       if (scanning_global_lru(sc) &&
> +           nr_dirty == nr_congested && nr_dirty != 0)
>                zone_set_flag(zone, ZONE_CONGESTED);
>
>        free_page_list(&free_pages);
>
> For memcg, wonder if we should make it per-memcg-per-zone congested.

Acked-by: Ying Han <yinghan@google.com>

--Ying

--002354470aa8949ec904a32187bb
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 12, 2011 at 8:10 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<br>
ZONE_CONGESTED should be a state of global memory reclaim.<br>
If not, a busy memcg sets this and give unnecessary throttoling in<br>
wait_iff_congested() against memory recalim in other contexts. This makes<b=
r>
system performance bad.<br>
<br>
I&#39;ll think about &quot;memcg is congested!&quot; flag is required or no=
t, later.<br>
But this fix is required 1st.<br>=A0</blockquote><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex;">
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0mm/vmscan.c | =A0 =A03 ++-<br>
=A01 file changed, 2 insertions(+), 1 deletion(-)<br>
<br>
Index: mmotm-May11/mm/vmscan.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-May11.orig/mm/vmscan.c<br>
+++ mmotm-May11/mm/vmscan.c<br>
@@ -941,7 +941,8 @@ keep_lumpy:<br>
 =A0 =A0 =A0 =A0 * back off and wait for congestion to clear because furthe=
r reclaim<br>
 =A0 =A0 =A0 =A0 * will encounter the same problem<br>
 =A0 =A0 =A0 =A0 */<br>
- =A0 =A0 =A0 if (nr_dirty =3D=3D nr_congested &amp;&amp; nr_dirty !=3D 0)<=
br>
+ =A0 =A0 =A0 if (scanning_global_lru(sc) &amp;&amp;<br>
+ =A0 =A0 =A0 =A0 =A0 nr_dirty =3D=3D nr_congested &amp;&amp; nr_dirty !=3D=
 0)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone_set_flag(zone, ZONE_CONGESTED);<br>
<br>
 =A0 =A0 =A0 =A0free_page_list(&amp;free_pages);<br>
<br></blockquote><div>For memcg, wonder if we should make it per-memcg-per-=
zone congested.</div><div>=A0</div></div><meta charset=3D"utf-8"><span clas=
s=3D"Apple-style-span" style=3D"border-collapse: collapse; font-family: ari=
al, sans-serif; font-size: 13px; "><font class=3D"Apple-style-span" color=
=3D"#525151">Acked</font>-by:=A0<font class=3D"Apple-style-span" color=3D"#=
525151">Ying Han</font>=A0&lt;<font class=3D"Apple-style-span" color=3D"#52=
5151"><a href=3D"mailto:yinghan@google.com">yinghan@google.com</a></font>&g=
t;</span><div>
<span class=3D"Apple-style-span" style=3D"border-collapse: collapse; font-f=
amily: arial, sans-serif; font-size: 13px; "><br></span></div><div><span cl=
ass=3D"Apple-style-span" style=3D"border-collapse: collapse; font-family: a=
rial, sans-serif; font-size: 13px; ">--Ying</span></div>

--002354470aa8949ec904a32187bb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
