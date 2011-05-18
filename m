Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7725F8D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 21:40:32 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p4I1eSab020067
	for <linux-mm@kvack.org>; Tue, 17 May 2011 18:40:28 -0700
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by kpbe18.cbf.corp.google.com with ESMTP id p4I1eOEn030238
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 May 2011 18:40:26 -0700
Received: by qyl38 with SMTP id 38so707064qyl.15
        for <linux-mm@kvack.org>; Tue, 17 May 2011 18:40:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110518085258.98f07390.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305671151-21993-1-git-send-email-yinghan@google.com>
	<1305671151-21993-2-git-send-email-yinghan@google.com>
	<20110518085258.98f07390.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 17 May 2011 18:40:23 -0700
Message-ID: <BANLkTinA3osWTkngOoZQ22oXaFR82=17Zg@mail.gmail.com>
Subject: Re: [PATCH 2/2] memcg: add memory.numastat api for numa statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5ce938c004a382f829
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016360e3f5ce938c004a382f829
Content-Type: text/plain; charset=ISO-8859-1

On Tue, May 17, 2011 at 4:52 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 17 May 2011 15:25:51 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > The new API exports numa_maps per-memcg basis. This is a piece of useful
> > information where it exports per-memcg page distribution across real numa
> > nodes.
> >
> > One of the usecase is evaluating application performance by combining
> this
> > information w/ the cpu allocation to the application.
> >
> > The output of the memory.numastat tries to follow w/ simiar format of
> numa_maps
> > like:
> >
> > <total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> >
> > $ cat /dev/cgroup/memory/memory.numa_stat
> > 292115 N0=36364 N1=166876 N2=39741 N3=49115
> >
> > Note: I noticed <total pages> is not equal to the sum of the rest of
> counters.
> > I might need to change the way get that counter, comments are welcomed.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
>
> Hmm, If I'm a user, I want to know file-cache is well balanced or where
> Anon is
> allocated from....Can't we have more precice one rather than
> total(anon+file) ?
>
> So, I don't like this patch. Could you show total,anon,file at least ?
>

Ok, then this is really becoming per-memcg numa_maps. Before I go ahead
posting the next version, this is something we are looking for:

total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...

please confirm?

thanks

--Ying

> Thanks,
> -Kame
>
>

--0016360e3f5ce938c004a382f829
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, May 17, 2011 at 4:52 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Tue, 17 May 2011 15:25:51 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; The new API exports numa_maps per-memcg basis. This is a piece of usef=
ul<br>
&gt; information where it exports per-memcg page distribution across real n=
uma<br>
&gt; nodes.<br>
&gt;<br>
&gt; One of the usecase is evaluating application performance by combining =
this<br>
&gt; information w/ the cpu allocation to the application.<br>
&gt;<br>
&gt; The output of the memory.numastat tries to follow w/ simiar format of =
numa_maps<br>
&gt; like:<br>
&gt;<br>
&gt; &lt;total pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;node 1 pages&gt=
; ...<br>
&gt;<br>
&gt; $ cat /dev/cgroup/memory/memory.numa_stat<br>
&gt; 292115 N0=3D36364 N1=3D166876 N2=3D39741 N3=3D49115<br>
&gt;<br>
&gt; Note: I noticed &lt;total pages&gt; is not equal to the sum of the res=
t of counters.<br>
&gt; I might need to change the way get that counter, comments are welcomed=
.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
</div>Hmm, If I&#39;m a user, I want to know file-cache is well balanced or=
 where Anon is<br>
allocated from....Can&#39;t we have more precice one rather than total(anon=
+file) ?<br>
<br>
So, I don&#39;t like this patch. Could you show total,anon,file at least ?<=
br></blockquote><div><br></div><div>Ok, then this is really becoming per-me=
mcg numa_maps. Before I go ahead posting the next version, this is somethin=
g we are looking for:</div>
<div><br></div><div>total=3D&lt;total pages&gt;=A0N0=3D&lt;node 0 pages&gt;=
 N1=3D&lt;node 1 pages&gt; ...</div><meta http-equiv=3D"content-type" conte=
nt=3D"text/html; charset=3Dutf-8"><div><meta http-equiv=3D"content-type" co=
ntent=3D"text/html; charset=3Dutf-8">anon=3D&lt;total anon pages&gt; N0=3D&=
lt;node 0 pages&gt; N1=3D&lt;node 1 pages&gt; ...</div>
<div><meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-=
8">file=3D&lt;total file pages&gt; N0=3D&lt;node 0 pages&gt; N1=3D&lt;node =
1 pages&gt; ...</div><div><br></div><div>please confirm?</div><div><br></di=
v><div>thanks</div>
<div><br></div><div>--Ying</div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--0016360e3f5ce938c004a382f829--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
