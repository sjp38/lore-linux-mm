Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 413126B0005
	for <linux-mm@kvack.org>; Sat, 25 Jun 2016 04:15:26 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so35907189wmr.0
        for <linux-mm@kvack.org>; Sat, 25 Jun 2016 01:15:26 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id e133si6863775lfe.23.2016.06.25.01.15.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Jun 2016 01:15:24 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id w130so23930668lfd.2
        for <linux-mm@kvack.org>; Sat, 25 Jun 2016 01:15:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160620143539.GG9892@dhcp22.suse.cz>
References: <1465754611-21398-1-git-send-email-masanori.yoshida.lkml@gmail.com>
 <20160620143539.GG9892@dhcp22.suse.cz>
From: Masanori YOSHIDA <masanori.yoshida.lkml@gmail.com>
Date: Sat, 25 Jun 2016 17:15:23 +0900
Message-ID: <CAM-Ae1Nx+4=p5ECwuRBnBDHuGVUhrM2XO-DsU3Lv=VdykGKc6Q@mail.gmail.com>
Subject: Re: [PATCH] Delete meaningless check of current_order in __rmqueue_fallback
Content-Type: multipart/alternative; boundary=001a1142c02e9aeb4b053615e342
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, rientjes@google.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, YOSHIDA Masanori <masanori.yoshida@gmail.com>

--001a1142c02e9aeb4b053615e342
Content-Type: text/plain; charset=UTF-8

2016-06-20 23:35 GMT+09:00 Michal Hocko <mhocko@kernel.org>:

> On Mon 13-06-16 03:03:31, YOSHIDA Masanori wrote:
> > From: YOSHIDA Masanori <masanori.yoshida@gmail.com>
> >
> > Signed-off-by: YOSHIDA Masanori <masanori.yoshida@gmail.com>
> > ---
> >  mm/page_alloc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 6903b69..db02967 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2105,7 +2105,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int
> order, int start_migratetype)
> >
> >       /* Find the largest possible block of pages in the other list */
> >       for (current_order = MAX_ORDER-1;
> > -                             current_order >= order && current_order <=
> MAX_ORDER-1;
> > +                             current_order >= order;
> >                               --current_order) {
> >               area = &(zone->free_area[current_order]);
> >               fallback_mt = find_suitable_fallback(area, current_order,
>
> This is incorrect. Guess what happens if the given order is 0. Hint,
> current_order is unsigned int.


I see. Thank you for replying.
And I should have noticed it before submission by using git-blame. Excuse
me.


> --
> Michal Hocko
> SUSE Labs
>

--001a1142c02e9aeb4b053615e342
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">2016=
-06-20 23:35 GMT+09:00 Michal Hocko <span dir=3D"ltr">&lt;<a href=3D"mailto=
:mhocko@kernel.org" target=3D"_blank">mhocko@kernel.org</a>&gt;</span>:<br>=
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><span class=3D"">On Mon 13-06-16 03:03:31, Y=
OSHIDA Masanori wrote:<br>
&gt; From: YOSHIDA Masanori &lt;<a href=3D"mailto:masanori.yoshida@gmail.co=
m">masanori.yoshida@gmail.com</a>&gt;<br>
&gt;<br>
&gt; Signed-off-by: YOSHIDA Masanori &lt;<a href=3D"mailto:masanori.yoshida=
@gmail.com">masanori.yoshida@gmail.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 mm/page_alloc.c | 2 +-<br>
&gt;=C2=A0 1 file changed, 1 insertion(+), 1 deletion(-)<br>
&gt;<br>
&gt; diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
&gt; index 6903b69..db02967 100644<br>
&gt; --- a/mm/page_alloc.c<br>
&gt; +++ b/mm/page_alloc.c<br>
&gt; @@ -2105,7 +2105,7 @@ __rmqueue_fallback(struct zone *zone, unsigned i=
nt order, int start_migratetype)<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/* Find the largest possible block of pages =
in the other list */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0for (current_order =3D MAX_ORDER-1;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0current_order &gt;=3D order &amp;&amp; c=
urrent_order &lt;=3D MAX_ORDER-1;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0current_order &gt;=3D order;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0--current_order) {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0area =3D &amp;(z=
one-&gt;free_area[current_order]);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0fallback_mt =3D =
find_suitable_fallback(area, current_order,<br>
<br>
</span>This is incorrect. Guess what happens if the given order is 0. Hint,=
<br>
current_order is unsigned int.</blockquote><div><br></div><div>I see. Thank=
 you for replying.</div><div>And I should have noticed it before submission=
 by using git-blame. Excuse me.=C2=A0</div><div>=C2=A0</div><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pa=
dding-left:1ex"><span class=3D"HOEnZb"><font color=3D"#888888">
--<br>
Michal Hocko<br>
SUSE Labs<br>
</font></span></blockquote></div></div><div class=3D"gmail_extra"><br></div=
></div>

--001a1142c02e9aeb4b053615e342--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
