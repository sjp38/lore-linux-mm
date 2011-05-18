Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EC52D8D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 23:05:25 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p4I35FRJ006569
	for <linux-mm@kvack.org>; Tue, 17 May 2011 20:05:15 -0700
Received: from qwh5 (qwh5.prod.google.com [10.241.194.197])
	by hpaq1.eem.corp.google.com with ESMTP id p4I358N6000992
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 May 2011 20:05:14 -0700
Received: by qwh5 with SMTP id 5so660187qwh.20
        for <linux-mm@kvack.org>; Tue, 17 May 2011 20:05:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110518110821.20c29c11.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305671151-21993-1-git-send-email-yinghan@google.com>
	<1305671151-21993-2-git-send-email-yinghan@google.com>
	<20110518085258.98f07390.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinA3osWTkngOoZQ22oXaFR82=17Zg@mail.gmail.com>
	<20110518110821.20c29c11.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 17 May 2011 20:05:08 -0700
Message-ID: <BANLkTi=PkC57r9s9B_1FTrPFv_QW37uuow@mail.gmail.com>
Subject: Re: [PATCH 2/2] memcg: add memory.numastat api for numa statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5cf7abfa04a3842739
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016360e3f5cf7abfa04a3842739
Content-Type: text/plain; charset=ISO-8859-1

On Tue, May 17, 2011 at 7:08 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 17 May 2011 18:40:23 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Tue, May 17, 2011 at 4:52 PM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > > On Tue, 17 May 2011 15:25:51 -0700
> > > Ying Han <yinghan@google.com> wrote:
> > >
> > > > The new API exports numa_maps per-memcg basis. This is a piece of
> useful
> > > > information where it exports per-memcg page distribution across real
> numa
> > > > nodes.
> > > >
> > > > One of the usecase is evaluating application performance by combining
> > > this
> > > > information w/ the cpu allocation to the application.
> > > >
> > > > The output of the memory.numastat tries to follow w/ simiar format of
> > > numa_maps
> > > > like:
> > > >
> > > > <total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > > >
> > > > $ cat /dev/cgroup/memory/memory.numa_stat
> > > > 292115 N0=36364 N1=166876 N2=39741 N3=49115
> > > >
> > > > Note: I noticed <total pages> is not equal to the sum of the rest of
> > > counters.
> > > > I might need to change the way get that counter, comments are
> welcomed.
> > > >
> > > > Signed-off-by: Ying Han <yinghan@google.com>
> > >
> > > Hmm, If I'm a user, I want to know file-cache is well balanced or where
> > > Anon is
> > > allocated from....Can't we have more precice one rather than
> > > total(anon+file) ?
> > >
> > > So, I don't like this patch. Could you show total,anon,file at least ?
> > >
> >
> > Ok, then this is really becoming per-memcg numa_maps. Before I go ahead
> > posting the next version, this is something we are looking for:
> >
> > total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> > file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
> >
>
> seems good.
>

Ok, thank you for clarifying that. I will look into the next post then.

--Ying

>
> THanks,
> -Kmae
>
>

--0016360e3f5cf7abfa04a3842739
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, May 17, 2011 at 7:08 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
On Tue, 17 May 2011 18:40:23 -0700<br>
<div><div></div><div class=3D"h5">Ying Han &lt;<a href=3D"mailto:yinghan@go=
ogle.com">yinghan@google.com</a>&gt; wrote:<br>
<br>
&gt; On Tue, May 17, 2011 at 4:52 PM, KAMEZAWA Hiroyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Tue, 17 May 2011 15:25:51 -0700<br>
&gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; The new API exports numa_maps per-memcg basis. This is a pie=
ce of useful<br>
&gt; &gt; &gt; information where it exports per-memcg page distribution acr=
oss real numa<br>
&gt; &gt; &gt; nodes.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; One of the usecase is evaluating application performance by =
combining<br>
&gt; &gt; this<br>
&gt; &gt; &gt; information w/ the cpu allocation to the application.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; The output of the memory.numastat tries to follow w/ simiar =
format of<br>
&gt; &gt; numa_maps<br>
&gt; &gt; &gt; like:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &lt;total pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;node =
1 pages&gt; ...<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; $ cat /dev/cgroup/memory/memory.numa_stat<br>
&gt; &gt; &gt; 292115 N0=3D36364 N1=3D166876 N2=3D39741 N3=3D49115<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Note: I noticed &lt;total pages&gt; is not equal to the sum =
of the rest of<br>
&gt; &gt; counters.<br>
&gt; &gt; &gt; I might need to change the way get that counter, comments ar=
e welcomed.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google=
.com">yinghan@google.com</a>&gt;<br>
&gt; &gt;<br>
&gt; &gt; Hmm, If I&#39;m a user, I want to know file-cache is well balance=
d or where<br>
&gt; &gt; Anon is<br>
&gt; &gt; allocated from....Can&#39;t we have more precice one rather than<=
br>
&gt; &gt; total(anon+file) ?<br>
&gt; &gt;<br>
&gt; &gt; So, I don&#39;t like this patch. Could you show total,anon,file a=
t least ?<br>
&gt; &gt;<br>
&gt;<br>
&gt; Ok, then this is really becoming per-memcg numa_maps. Before I go ahea=
d<br>
&gt; posting the next version, this is something we are looking for:<br>
&gt;<br>
&gt; total=3D&lt;total pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;node 1 =
pages&gt; ...<br>
&gt; anon=3D&lt;total anon pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;nod=
e 1 pages&gt; ...<br>
&gt; file=3D&lt;total file pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;nod=
e 1 pages&gt; ...<br>
&gt;<br>
<br>
</div></div>seems good.<br></blockquote><div><br></div><div>Ok, thank you f=
or clarifying that. I will look into the next post then.</div><div><br></di=
v><div>--Ying=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

<br>
THanks,<br>
-Kmae<br>
<br>
</blockquote></div><br>

--0016360e3f5cf7abfa04a3842739--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
