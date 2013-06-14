Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id F2A336B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 14:13:26 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa11so888395pad.5
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 11:13:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130614111034.GA306@gmail.com>
References: <1371204471-13518-1-git-send-email-heesub.shin@samsung.com>
	<20130614111034.GA306@gmail.com>
Date: Sat, 15 Jun 2013 03:13:26 +0900
Message-ID: <CALSv+Dht=1ghRmiXdLwkFcXgRTwV=erSeoXc2AEh7+8XmHh1xQ@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: remove redundant querying to shrinker
From: HeeSub Shin <heesub@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bacb51600785404df213437
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Heesub Shin <heesub.shin@samsung.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, riel@redhat.com, kyungmin.park@samsung.com, d.j.shin@samsung.com, sunae.seo@samsung.com

--047d7bacb51600785404df213437
Content-Type: text/plain; charset=ISO-8859-1

Hello,

On Fri, Jun 14, 2013 at 8:10 PM, Minchan Kim <minchan@kernel.org> wrote:

>
> Hello,
>
> On Fri, Jun 14, 2013 at 07:07:51PM +0900, Heesub Shin wrote:
> > shrink_slab() queries each slab cache to get the number of
> > elements in it. In most cases such queries are cheap but,
> > on some caches. For example, Android low-memory-killer,
> > which is operates as a slab shrinker, does relatively
> > long calculation once invoked and it is quite expensive.
>
> LMK as shrinker is really bad, which everybody didn't want
> when we reviewed it a few years ago so that's a one of reason
> LMK couldn't be promoted to mainline yet. So your motivation is
> already not atrractive. ;-)
>
> >
> > This patch removes redundant queries to shrinker function
> > in the loop of shrink batch.
>
> I didn't review the patch and others don't want it, I guess.
> Because slab shrink is under construction and many patches were
> already merged into mmtom. Please look at latest mmotm tree.
>
>         git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git


>
> If you concern is still in there and it's really big concern of MM
> we should take care, NOT LMK, plese, resend it.
>
>
I've noticed that there are huge changes there in the recent mmotm and you
guys already settled the issue of my concern. I usually keep track changes
in recent mm-tree, but this time I didn't. My bad :-)

Many thanks for your comments!

--
Heesub


> Thanks.
>
> --
> Kind regards,
> Minchan Kim
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--047d7bacb51600785404df213437
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,<br><br><div class=3D"gmail_quote">On Fri, Jun 14, 2013 at 8:10 PM, M=
inchan Kim <span dir=3D"ltr">&lt;<a href=3D"mailto:minchan@kernel.org" targ=
et=3D"_blank">minchan@kernel.org</a>&gt;</span> wrote:<br><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">
<br>
Hello,<br>
<div class=3D"im"><br>
On Fri, Jun 14, 2013 at 07:07:51PM +0900, Heesub Shin wrote:<br>
&gt; shrink_slab() queries each slab cache to get the number of<br>
&gt; elements in it. In most cases such queries are cheap but,<br>
&gt; on some caches. For example, Android low-memory-killer,<br>
&gt; which is operates as a slab shrinker, does relatively<br>
&gt; long calculation once invoked and it is quite expensive.<br>
<br>
</div>LMK as shrinker is really bad, which everybody didn&#39;t want<br>
when we reviewed it a few years ago so that&#39;s a one of reason<br>
LMK couldn&#39;t be promoted to mainline yet. So your motivation is<br>
already not atrractive. ;-)<br>
<div class=3D"im"><br>
&gt;<br>
&gt; This patch removes redundant queries to shrinker function<br>
&gt; in the loop of shrink batch.<br>
<br>
</div>I didn&#39;t review the patch and others don&#39;t want it, I guess.<=
br>
Because slab shrink is under construction and many patches were<br>
already merged into mmtom. Please look at latest mmotm tree.<br>
<br>
=A0 =A0 =A0 =A0 git://<a href=3D"http://git.kernel.org/pub/scm/linux/kernel=
/git/mhocko/mm.git" target=3D"_blank">git.kernel.org/pub/scm/linux/kernel/g=
it/mhocko/mm.git</a></blockquote><blockquote class=3D"gmail_quote" style=3D=
"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
<br>
If you concern is still in there and it&#39;s really big concern of MM<br>
we should take care, NOT LMK, plese, resend it.<br><br></blockquote><div><d=
iv><br></div><div>I&#39;ve noticed that there are huge changes there in the=
 recent mmotm and you guys already settled the issue of my concern. I usual=
ly keep track changes in recent mm-tree, but this time I didn&#39;t. My bad=
 :-)</div>
<div><br></div><div>Many thanks for your comments!</div><div><br></div><div=
>--</div><div>Heesub=A0</div></div><div>=A0</div><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex">

Thanks.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
Kind regards,<br>
Minchan Kim<br>
</font></span><div class=3D"HOEnZb"><div class=3D"h5"><br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</div></div></blockquote></div><br>

--047d7bacb51600785404df213437--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
