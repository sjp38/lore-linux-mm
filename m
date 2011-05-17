Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 97E186B0022
	for <linux-mm@kvack.org>; Tue, 17 May 2011 10:45:28 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p4HEjKRJ021542
	for <linux-mm@kvack.org>; Tue, 17 May 2011 07:45:20 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by wpaz1.hot.corp.google.com with ESMTP id p4HEiMrT012696
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 May 2011 07:45:19 -0700
Received: by qwc9 with SMTP id 9so500275qwc.27
        for <linux-mm@kvack.org>; Tue, 17 May 2011 07:45:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110517081100.GZ16531@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
	<BANLkTikHhK8S-fMpe=KOYCF0kmXotHKCOQ@mail.gmail.com>
	<20110513072043.GE18610@cmpxchg.org>
	<BANLkTiky6=xwqb_ML1wg=8Gg=BO0nmeUog@mail.gmail.com>
	<20110517081100.GZ16531@cmpxchg.org>
Date: Tue, 17 May 2011 07:45:11 -0700
Message-ID: <BANLkTikdqKM-09YHOuf6MqdJBvi_ZJ5u2g@mail.gmail.com>
Subject: Re: [rfc patch 0/6] mm: memcg naturalization
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa8b2c50104a379d15a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--002354470aa8b2c50104a379d15a
Content-Type: text/plain; charset=ISO-8859-1

On Tue, May 17, 2011 at 1:11 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Mon, May 16, 2011 at 05:53:04PM -0700, Ying Han wrote:
> > On Fri, May 13, 2011 at 12:20 AM, Johannes Weiner <hannes@cmpxchg.org
> >wrote:
> >
> > > On Thu, May 12, 2011 at 11:53:37AM -0700, Ying Han wrote:
> > > > On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner <hannes@cmpxchg.org
> >
> > > wrote:
> > > >
> > > > > Hi!
> > > > >
> > > > > Here is a patch series that is a result of the memcg discussions on
> > > > > LSF (memcg-aware global reclaim, global lru removal, struct
> > > > > page_cgroup reduction, soft limit implementation) and the recent
> > > > > feature discussions on linux-mm.
> > > > >
> > > > > The long-term idea is to have memcgs no longer bolted to the side
> of
> > > > > the mm code, but integrate it as much as possible such that there
> is a
> > > > > native understanding of containers, and that the traditional !memcg
> > > > > setup is just a singular group.  This series is an approach in that
> > > > > direction.
> > >
> >
> > This sounds like a good long term plan. Now I would wonder should we take
> it
> > step by step by doing:
> >
> > 1. improving the existing soft_limit reclaim from RB-tree based to
> link-list
> > based, also in a round_robin fashion.
> > We can keep the existing APIs but only changing the underlying
> > implementation of  mem_cgroup_soft_limit_reclaim()
> >
> > 2. remove the global lru list after the first one being proved to be
> > efficient.
> >
> > 3. then have better integration of memcg reclaim to the mm code.
>
> I chose to go the other because it did not seem more complex to me and
> fixed many things we had planned anyway.  Deeper integration, better
> soft limit implementation (including better pressure distribution,
> enforcement also from direct reclaim, not just kswapd), global lru removal
> etc.


> That ground work was a bit unwieldy and I think quite some confusion
> ensued, but I am currently reorganizing, cleaning up, and documenting.
> I expect the next version to be much easier to understand.
>
> The three steps are still this:
>
> 1. make traditional reclaim memcg-aware.
>
> 2. improve soft limit based on 1.
>

I don't see the soft_limit round-robin implementation on the patch 6/6,
maybe I missed it somewhere. I have my patch posted which does the
linked-list
round-robin across memcgs per-zone , do you have plan to merge them together
?

>
> 3. remove global lru based on 1.
>


>
> But 1. already effectively disables the global LRU for memcg-enabled
> kernels, so 3. can be deferred until we are comfortable with 1.
>
> Thank you for the details and clarification, and looking forward to your
next post.

--Ying

>        Hannes
>

--002354470aa8b2c50104a379d15a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, May 17, 2011 at 1:11 AM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Mon, May 16, 2011 at 05:53:04PM -0700, Ying Han wrote:=
<br>
&gt; On Fri, May 13, 2011 at 12:20 AM, Johannes Weiner &lt;<a href=3D"mailt=
o:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt;wrote:<br>
&gt;<br>
&gt; &gt; On Thu, May 12, 2011 at 11:53:37AM -0700, Ying Han wrote:<br>
&gt; &gt; &gt; On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner &lt;<a href=
=3D"mailto:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt;<br>
&gt; &gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Hi!<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Here is a patch series that is a result of the memcg di=
scussions on<br>
&gt; &gt; &gt; &gt; LSF (memcg-aware global reclaim, global lru removal, st=
ruct<br>
&gt; &gt; &gt; &gt; page_cgroup reduction, soft limit implementation) and t=
he recent<br>
&gt; &gt; &gt; &gt; feature discussions on linux-mm.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; The long-term idea is to have memcgs no longer bolted t=
o the side of<br>
&gt; &gt; &gt; &gt; the mm code, but integrate it as much as possible such =
that there is a<br>
&gt; &gt; &gt; &gt; native understanding of containers, and that the tradit=
ional !memcg<br>
&gt; &gt; &gt; &gt; setup is just a singular group. =A0This series is an ap=
proach in that<br>
&gt; &gt; &gt; &gt; direction.<br>
&gt; &gt;<br>
&gt;<br>
&gt; This sounds like a good long term plan. Now I would wonder should we t=
ake it<br>
&gt; step by step by doing:<br>
&gt;<br>
&gt; 1. improving the existing soft_limit reclaim from RB-tree based to lin=
k-list<br>
&gt; based, also in a round_robin fashion.<br>
&gt; We can keep the existing APIs but only changing the underlying<br>
&gt; implementation of =A0mem_cgroup_soft_limit_reclaim()<br>
&gt;<br>
&gt; 2. remove the global lru list after the first one being proved to be<b=
r>
&gt; efficient.<br>
&gt;<br>
&gt; 3. then have better integration of memcg reclaim to the mm code.<br>
<br>
</div>I chose to go the other because it did not seem more complex to me an=
d<br>
fixed many things we had planned anyway. =A0Deeper integration, better<br>
soft limit implementation (including better pressure distribution,<br>
enforcement also from direct reclaim, not just kswapd),=A0global lru=A0remo=
val etc.</blockquote><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
That ground work was a bit unwieldy and I think quite some confusion<br>
ensued, but I am currently reorganizing, cleaning up, and documenting.<br>
I expect the next version to be much easier to understand.<br>
<br>
The three steps are still this:<br>
<br>
1. make traditional reclaim memcg-aware.<br>
<br>
2. improve soft limit based on 1.<br></blockquote><div><br></div><div>I don=
&#39;t see the soft_limit round-robin implementation on the patch 6/6, mayb=
e I missed it somewhere. I have my patch posted which does the linked-list<=
/div>
<div>round-robin across memcgs per-zone , do you have plan to merge them to=
gether ?</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">
<br>
3. remove global lru based on 1.<br></blockquote><div>=A0</div><blockquote =
class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid=
;padding-left:1ex;">
<br>
But 1. already effectively disables the global LRU for memcg-enabled<br>
kernels, so 3. can be deferred until we are comfortable with 1.<br>
<br></blockquote><div>Thank you for the details and=A0clarification, and lo=
oking forward to your next post.=A0</div><div>=A0</div><div>--Ying</div><bl=
ockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #=
ccc solid;padding-left:1ex;">

 =A0 =A0 =A0 =A0Hannes<br>
</blockquote></div><br>

--002354470aa8b2c50104a379d15a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
