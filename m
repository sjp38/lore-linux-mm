Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 54E276B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 23:23:11 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p4K3N7Ap008207
	for <linux-mm@kvack.org>; Thu, 19 May 2011 20:23:07 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by wpaz21.hot.corp.google.com with ESMTP id p4K3N6P1001774
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 May 2011 20:23:06 -0700
Received: by qwk3 with SMTP id 3so1670368qwk.19
        for <linux-mm@kvack.org>; Thu, 19 May 2011 20:23:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DD5D92B.8030209@jp.fujitsu.com>
References: <4DD5D92B.8030209@jp.fujitsu.com>
Date: Thu, 19 May 2011 20:23:05 -0700
Message-ID: <BANLkTik3cC9f5M6xB4zpVPpRg8Y_+MtTaw@mail.gmail.com>
Subject: Re: [PATCH V2 2/2] change shrinker API by passing shrink_control struct
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefdadf8b6004a3aca3ae
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

--0016e64aefdadf8b6004a3aca3ae
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 19, 2011 at 7:59 PM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

> > Hmm, got Nick's email wrong.
> >
> > --Ying
>
> Ping.
> Can you please explain current status? When I can see your answer?
>

The patch has been merged into mmotm-04-29-16-25. Sorry if there is a
question that I missed ?

--Ying

>
>
> >
> > On Tue, Apr 26, 2011 at 6:15 PM, Ying Han <yinghan@google.com> wrote:
> >> On Tue, Apr 26, 2011 at 5:47 PM, KOSAKI Motohiro
> >> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >>>> > >  {
> >>>> > >       struct xfs_mount *mp;
> >>>> > >       struct xfs_perag *pag;
> >>>> > >       xfs_agnumber_t  ag;
> >>>> > >       int             reclaimable;
> >>>> > > +     int nr_to_scan = sc->nr_slab_to_reclaim;
> >>>> > > +     gfp_t gfp_mask = sc->gfp_mask;
> >>>> >
> >>>> > And, this very near meaning field .nr_scanned and
> .nr_slab_to_reclaim
> >>>> > poped up new question.
> >>>> > Why don't we pass more clever slab shrinker target? Why do we need
> pass
> >>>> > similar two argument?
> >>>> >
> >>>>
> >>>> I renamed the nr_slab_to_reclaim and nr_scanned in shrink struct.
> >>>
> >>> Oh no. that's not naming issue. example, Nick's previous similar patch
> pass
> >>> zone-total-pages and how-much-scanned-pages. (ie shrink_slab don't
> calculate
> >>> current magical target scanning objects anymore)
> >>>        ie,  "4 *  max_pass  * (scanned / nr- lru_pages-in-zones)"
> >>>
> >>> Instead, individual shrink_slab callback calculate this one.
> >>> see git://
> git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> >>>
> >>> I'm curious why you change the design from another guy's previous very
> similar effort and
> >>> We have to be convinced which is better.
> >>
> >> Thank you for the pointer. My patch is intended to consolidate all
> >> existing parameters passed from reclaim code
> >> to the shrinker.
> >>
> >> Talked w/ Nick and Andrew from last LSF,  we agree that this patch
> >> will be useful for other extensions later which allows us easily
> >> adding extensions to the shrinkers without shrinker files. Nick and I
> >> talked about the effort later to pass the nodemask down to the
> >> shrinker. He is cc-ed in the thread. Another thing I would like to
> >> repost is to add the reclaim priority down to the shrinker, which we
> >> won't throw tons of page caches pages by reclaiming one inode slab
> >> object.
> >>
> >> --Ying
>
>
>

--0016e64aefdadf8b6004a3aca3ae
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 19, 2011 at 7:59 PM, KOSAKI =
Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujitsu=
.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex;">
&gt; Hmm, got Nick&#39;s email wrong.<br>
&gt;<br>
&gt; --Ying<br>
<br>
Ping.<br>
Can you please explain current status? When I can see your answer?<br></blo=
ckquote><div>=A0</div><div>The patch has been merged into mmotm-04-29-16-25=
. Sorry if there is a question that I missed ?</div><div><br></div><div>
--Ying</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex;">
<br>
<br>
&gt;<br>
&gt; On Tue, Apr 26, 2011 at 6:15 PM, Ying Han &lt;<a href=3D"mailto:yingha=
n@google.com">yinghan@google.com</a>&gt; wrote:<br>
&gt;&gt; On Tue, Apr 26, 2011 at 5:47 PM, KOSAKI Motohiro<br>
&gt;&gt; &lt;<a href=3D"mailto:kosaki.motohiro@jp.fujitsu.com">kosaki.motoh=
iro@jp.fujitsu.com</a>&gt; wrote:<br>
&gt;&gt;&gt;&gt; &gt; &gt; =A0{<br>
&gt;&gt;&gt;&gt; &gt; &gt; =A0 =A0 =A0 struct xfs_mount *mp;<br>
&gt;&gt;&gt;&gt; &gt; &gt; =A0 =A0 =A0 struct xfs_perag *pag;<br>
&gt;&gt;&gt;&gt; &gt; &gt; =A0 =A0 =A0 xfs_agnumber_t =A0ag;<br>
&gt;&gt;&gt;&gt; &gt; &gt; =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 reclaima=
ble;<br>
&gt;&gt;&gt;&gt; &gt; &gt; + =A0 =A0 int nr_to_scan =3D sc-&gt;nr_slab_to_r=
eclaim;<br>
&gt;&gt;&gt;&gt; &gt; &gt; + =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br=
>
&gt;&gt;&gt;&gt; &gt;<br>
&gt;&gt;&gt;&gt; &gt; And, this very near meaning field .nr_scanned and .nr=
_slab_to_reclaim<br>
&gt;&gt;&gt;&gt; &gt; poped up new question.<br>
&gt;&gt;&gt;&gt; &gt; Why don&#39;t we pass more clever slab shrinker targe=
t? Why do we need pass<br>
&gt;&gt;&gt;&gt; &gt; similar two argument?<br>
&gt;&gt;&gt;&gt; &gt;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt; I renamed the nr_slab_to_reclaim and nr_scanned in shrink =
struct.<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; Oh no. that&#39;s not naming issue. example, Nick&#39;s previo=
us similar patch pass<br>
&gt;&gt;&gt; zone-total-pages and how-much-scanned-pages. (ie shrink_slab d=
on&#39;t calculate<br>
&gt;&gt;&gt; current magical target scanning objects anymore)<br>
&gt;&gt;&gt; =A0 =A0 =A0 =A0ie, =A0&quot;4 * =A0max_pass =A0* (scanned / nr=
- lru_pages-in-zones)&quot;<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; Instead, individual shrink_slab callback calculate this one.<b=
r>
&gt;&gt;&gt; see git://<a href=3D"http://git.kernel.org/pub/scm/linux/kerne=
l/git/npiggin/linux-npiggin.git" target=3D"_blank">git.kernel.org/pub/scm/l=
inux/kernel/git/npiggin/linux-npiggin.git</a><br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; I&#39;m curious why you change the design from another guy&#39=
;s previous very similar effort and<br>
&gt;&gt;&gt; We have to be convinced which is better.<br>
&gt;&gt;<br>
&gt;&gt; Thank you for the pointer. My patch is intended to consolidate all=
<br>
&gt;&gt; existing parameters passed from reclaim code<br>
&gt;&gt; to the shrinker.<br>
&gt;&gt;<br>
&gt;&gt; Talked w/ Nick and Andrew from last LSF, =A0we agree that this pat=
ch<br>
&gt;&gt; will be useful for other extensions later which allows us easily<b=
r>
&gt;&gt; adding extensions to the shrinkers without shrinker files. Nick an=
d I<br>
&gt;&gt; talked about the effort later to pass the nodemask down to the<br>
&gt;&gt; shrinker. He is cc-ed in the thread. Another thing I would like to=
<br>
&gt;&gt; repost is to add the reclaim priority down to the shrinker, which =
we<br>
&gt;&gt; won&#39;t throw tons of page caches pages by reclaiming one inode =
slab<br>
&gt;&gt; object.<br>
&gt;&gt;<br>
&gt;&gt; --Ying<br>
<br>
<br>
</blockquote></div><br>

--0016e64aefdadf8b6004a3aca3ae--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
