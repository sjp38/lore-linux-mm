Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 677106B13F3
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 10:36:37 -0500 (EST)
Received: by vcbf13 with SMTP id f13so3393260vcb.14
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 07:36:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120203145304.GA18335@tiehlicka.suse.cz>
References: <1328258627-2241-1-git-send-email-geunsik.lim@gmail.com>
	<20120203133950.GA1690@cmpxchg.org>
	<20120203145304.GA18335@tiehlicka.suse.cz>
Date: Sat, 4 Feb 2012 00:36:36 +0900
Message-ID: <CAGFP0LK4_PhKLJVtMhsNe4YfUQoHcoTK3hJhHaBy51f359ef7A@mail.gmail.com>
Subject: Re: [PATCH] Handling of unused variable 'do-numainfo on compilation time
From: Geunsik Lim <geunsik.lim@gmail.com>
Content-Type: multipart/alternative; boundary=20cf3071c6aeff47c704b81113e0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>

--20cf3071c6aeff47c704b81113e0
Content-Type: text/plain; charset=UTF-8

On Fri, Feb 3, 2012 at 11:53 PM, Michal Hocko <mhocko@suse.cz> wrote:

> On Fri 03-02-12 14:39:50, Johannes Weiner wrote:
> > Michal, this keeps coming up, please decide between the proposed
> > solutions ;-)
>
> Hmm, I thought we already sorted this out
> https://lkml.org/lkml/2012/1/26/25 ?
>
> I don't know previous history about this variable.
Is it same? Please, adjust this patch or fix the unsuitable
variable 'do_numainfo' as I mentioned.

> >
> > On Fri, Feb 03, 2012 at 05:43:47PM +0900, Geunsik Lim wrote:
> > > Actually, Usage of the variable 'do_numainfo'is not suitable for gcc
> compiler.
> > > Declare the variable 'do_numainfo' if the number of NUMA nodes > 1.
> > >
> > > Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
> > > ---
> > >  mm/memcontrol.c |    5 ++++-
> > >  1 files changed, 4 insertions(+), 1 deletions(-)
> > >
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 556859f..4e17ac5 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -776,7 +776,10 @@ static void memcg_check_events(struct mem_cgroup
> *memcg, struct page *page)
> > >     /* threshold event is triggered in finer grain than soft limit */
> > >     if (unlikely(mem_cgroup_event_ratelimit(memcg,
> > >
> MEM_CGROUP_TARGET_THRESH))) {
> > > -           bool do_softlimit, do_numainfo;
> > > +           bool do_softlimit;
> > > +#if MAX_NUMNODES > 1
> > > +                bool do_numainfo;
> > > +#endif
> > >
> > >             do_softlimit = mem_cgroup_event_ratelimit(memcg,
> > >
> MEM_CGROUP_TARGET_SOFTLIMIT);
> > > --
> > > 1.7.8.1
> > >
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>



-- 
----
Best regards,
Geunsik Lim, Samsung Electronics
http://leemgs.fedorapeople.org
----
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

--20cf3071c6aeff47c704b81113e0
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Feb 3, 2012 at 11:53 PM, Michal =
Hocko <span dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.c=
z</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margi=
n:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div class=3D"im">On Fri 03-02-12 14:39:50, Johannes Weiner wrote:<br>
&gt; Michal, this keeps coming up, please decide between the proposed<br>
&gt; solutions ;-)<br>
<br>
</div>Hmm, I thought we already sorted this out <a href=3D"https://lkml.org=
/lkml/2012/1/26/25" target=3D"_blank">https://lkml.org/lkml/2012/1/26/25</a=
> ?<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br></div></div></blockquote><div>I=
 don&#39;t know previous history about this variable.=C2=A0</div><div>Is it=
 same? Please, adjust this patch=C2=A0or fix the unsuitable=C2=A0</div><div=
>variable &#39;do_numainfo&#39; as I mentioned.=C2=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5">
&gt;<br>
&gt; On Fri, Feb 03, 2012 at 05:43:47PM +0900, Geunsik Lim wrote:<br>
&gt; &gt; Actually, Usage of the variable &#39;do_numainfo&#39;is not suita=
ble for gcc compiler.<br>
&gt; &gt; Declare the variable &#39;do_numainfo&#39; if the number of NUMA =
nodes &gt; 1.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Geunsik Lim &lt;<a href=3D"mailto:geunsik.lim@sams=
ung.com">geunsik.lim@samsung.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt; =C2=A0mm/memcontrol.c | =C2=A0 =C2=A05 ++++-<br>
&gt; &gt; =C2=A01 files changed, 4 insertions(+), 1 deletions(-)<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; &gt; index 556859f..4e17ac5 100644<br>
&gt; &gt; --- a/mm/memcontrol.c<br>
&gt; &gt; +++ b/mm/memcontrol.c<br>
&gt; &gt; @@ -776,7 +776,10 @@ static void memcg_check_events(struct mem_cg=
roup *memcg, struct page *page)<br>
&gt; &gt; =C2=A0 =C2=A0 /* threshold event is triggered in finer grain than=
 soft limit */<br>
&gt; &gt; =C2=A0 =C2=A0 if (unlikely(mem_cgroup_event_ratelimit(memcg,<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 MEM_CGROUP_TARGET_THRESH))) {<br>
&gt; &gt; - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool do_softlimit, do_numain=
fo;<br>
&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool do_softlimit;<br>
&gt; &gt; +#if MAX_NUMNODES &gt; 1<br>
&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bool do_=
numainfo;<br>
&gt; &gt; +#endif<br>
&gt; &gt;<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do_softlimit =3D mem_cg=
roup_event_ratelimit(memcg,<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 MEM_CGROUP_TARGET_SOFTLIMIT);<br>
&gt; &gt; --<br>
&gt; &gt; 1.7.8.1<br>
&gt; &gt;<br>
<br>
</div></div><span class=3D"HOEnZb"><font color=3D"#888888">--<br>
Michal Hocko<br>
SUSE Labs<br>
SUSE LINUX s.r.o.<br>
Lihovarska 1060/12<br>
190 00 Praha 9<br>
Czech Republic<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div>----</div><div>Best regards,</div><div>Geunsik Lim, Samsung Electron=
ics</div><div><a href=3D"http://leemgs.fedorapeople.org" target=3D"_blank">=
http://leemgs.fedorapeople.org</a></div>
<div>----</div><div>To unsubscribe from this list: send the line &quot;unsu=
bscribe linux-kernel&quot; in</div><div>the body of a message to <a href=3D=
"mailto:majordomo@vger.kernel.org" target=3D"_blank">majordomo@vger.kernel.=
org</a></div>
<div>More majordomo info at =C2=A0<a href=3D"http://vger.kernel.org/majordo=
mo-info.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html<=
/a></div><div>Please read the FAQ at =C2=A0<a href=3D"http://www.tux.org/lk=
ml/" target=3D"_blank">http://www.tux.org/lkml/</a></div>
<br>

--20cf3071c6aeff47c704b81113e0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
