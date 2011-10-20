Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AC6096B002C
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 14:36:14 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p9KIa78x001205
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 11:36:07 -0700
Received: from qabg14 (qabg14.prod.google.com [10.224.20.206])
	by wpaz21.hot.corp.google.com with ESMTP id p9KIXXxJ009413
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 11:36:06 -0700
Received: by qabg14 with SMTP id g14so2662998qab.7
        for <linux-mm@kvack.org>; Thu, 20 Oct 2011 11:36:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201110202051.33288.nai.xia@gmail.com>
References: <201110122012.33767.pluto@agmk.net>
	<CA+55aFwf75oJ3JJ2aCR8TJJm_oLireD6SDO+43GveVVb8vGw1w@mail.gmail.com>
	<alpine.LSU.2.00.1110191234570.6900@sister.anvils>
	<201110202051.33288.nai.xia@gmail.com>
Date: Thu, 20 Oct 2011 11:36:06 -0700
Message-ID: <CANsGZ6a6_q8+88FRV2froBsVEq7GhtKd9fRnB-0M2MD3a7tnSw@mail.gmail.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
From: Hugh Dickins <hughd@google.com>
Content-Type: multipart/alternative; boundary=20cf307f346ac1643804afbf3a56
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nai.xia@gmail.com
Cc: arekm@pld-linux.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, jpiszcz@lucidpixels.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pawel Sikora <pluto@agmk.net>, Andrea Arcangeli <aarcange@redhat.com>

--20cf307f346ac1643804afbf3a56
Content-Type: text/plain; charset=UTF-8

I'm travelling at the moment, my brain is not in gear, the source is not in
front of me, and I'm not used to typing on my phone much!  Excuses, excuses

I flip between thinking you are right, and I'm a fool, and thinking you are
wrong, and I'm still a fool.

Please work it out with Linus, Andrea and Mel: I may not be able to reply
for a couple of days - thanks.

Hugh
On Oct 20, 2011 5:51 AM, "Nai Xia" <nai.xia@gmail.com> wrote:

> On Thursday 20 October 2011 03:42:15 Hugh Dickins wrote:
> > On Wed, 19 Oct 2011, Linus Torvalds wrote:
> > > On Wed, Oct 19, 2011 at 12:43 AM, Mel Gorman <mgorman@suse.de> wrote:
> > > >
> > > > My vote is with the migration change. While there are occasionally
> > > > patches to make migration go faster, I don't consider it a hot path.
> > > > mremap may be used intensively by JVMs so I'd loathe to hurt it.
> > >
> > > Ok, everybody seems to like that more, and it removes code rather than
> > > adds it, so I certainly prefer it too. Pawel, can you test that other
> > > patch (to mm/migrate.c) that Hugh posted? Instead of the mremap vma
> > > locking patch that you already verified for your setup?
> > >
> > > Hugh - that one didn't have a changelog/sign-off, so if you could
> > > write that up, and Pawel's testing is successful, I can apply it...
> > > Looks like we have acks from both Andrea and Mel.
> >
> > Yes, I'm glad to have that input from Andrea and Mel, thank you.
> >
> > Here we go.  I can't add a Tested-by since Pawel was reporting on the
> > alternative patch, but perhaps you'll be able to add that in later.
> >
> > I may have read too much into Pawel's mail, but it sounded like he
> > would have expected an eponymous find_get_pages() lockup by now,
> > and was pleased that this patch appeared to have cured that.
> >
> > I've spent quite a while trying to explain find_get_pages() lockup by
> > a missed migration entry, but I just don't see it: I don't expect this
> > (or the alternative) patch to do anything to fix that problem.  I won't
> > mind if it magically goes away, but I expect we'll need more info from
> > the debug patch I sent Justin a couple of days ago.
>
> Hi Hugh,
>
> Will you please look into my explanation in my reply to Andrea in this
> thread
> and see if it's what you are seeking?
>
>
> Thanks,
>
> Nai Xia
>
>
> >
> > Ah, I'd better send the patch separately as
> > "[PATCH] mm: fix race between mremap and removing migration entry":
> > Pawel's "l" makes my old alpine setup choose quoted printable when
> > I reply to your mail.
> >
> > Hugh
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
>

--20cf307f346ac1643804afbf3a56
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p>I&#39;m travelling at the moment, my brain is not in gear, the source is=
 not in front of me, and I&#39;m not used to typing on my phone much!=C2=A0=
 Excuses, excuses</p>
<p>I flip between thinking you are right, and I&#39;m a fool, and thinking =
you are wrong, and I&#39;m still a fool.</p>
<p>Please work it out with Linus, Andrea and Mel: I may not be able to repl=
y for a couple of days - thanks.</p>
<p>Hugh </p>
<div class=3D"gmail_quote">On Oct 20, 2011 5:51 AM, &quot;Nai Xia&quot; &lt=
;<a href=3D"mailto:nai.xia@gmail.com">nai.xia@gmail.com</a>&gt; wrote:<br t=
ype=3D"attribution"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex">
On Thursday 20 October 2011 03:42:15 Hugh Dickins wrote:<br>
&gt; On Wed, 19 Oct 2011, Linus Torvalds wrote:<br>
&gt; &gt; On Wed, Oct 19, 2011 at 12:43 AM, Mel Gorman &lt;<a href=3D"mailt=
o:mgorman@suse.de">mgorman@suse.de</a>&gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; My vote is with the migration change. While there are occasi=
onally<br>
&gt; &gt; &gt; patches to make migration go faster, I don&#39;t consider it=
 a hot path.<br>
&gt; &gt; &gt; mremap may be used intensively by JVMs so I&#39;d loathe to =
hurt it.<br>
&gt; &gt;<br>
&gt; &gt; Ok, everybody seems to like that more, and it removes code rather=
 than<br>
&gt; &gt; adds it, so I certainly prefer it too. Pawel, can you test that o=
ther<br>
&gt; &gt; patch (to mm/migrate.c) that Hugh posted? Instead of the mremap v=
ma<br>
&gt; &gt; locking patch that you already verified for your setup?<br>
&gt; &gt;<br>
&gt; &gt; Hugh - that one didn&#39;t have a changelog/sign-off, so if you c=
ould<br>
&gt; &gt; write that up, and Pawel&#39;s testing is successful, I can apply=
 it...<br>
&gt; &gt; Looks like we have acks from both Andrea and Mel.<br>
&gt;<br>
&gt; Yes, I&#39;m glad to have that input from Andrea and Mel, thank you.<b=
r>
&gt;<br>
&gt; Here we go. =C2=A0I can&#39;t add a Tested-by since Pawel was reportin=
g on the<br>
&gt; alternative patch, but perhaps you&#39;ll be able to add that in later=
.<br>
&gt;<br>
&gt; I may have read too much into Pawel&#39;s mail, but it sounded like he=
<br>
&gt; would have expected an eponymous find_get_pages() lockup by now,<br>
&gt; and was pleased that this patch appeared to have cured that.<br>
&gt;<br>
&gt; I&#39;ve spent quite a while trying to explain find_get_pages() lockup=
 by<br>
&gt; a missed migration entry, but I just don&#39;t see it: I don&#39;t exp=
ect this<br>
&gt; (or the alternative) patch to do anything to fix that problem. =C2=A0I=
 won&#39;t<br>
&gt; mind if it magically goes away, but I expect we&#39;ll need more info =
from<br>
&gt; the debug patch I sent Justin a couple of days ago.<br>
<br>
Hi Hugh,<br>
<br>
Will you please look into my explanation in my reply to Andrea in this thre=
ad<br>
and see if it&#39;s what you are seeking?<br>
<br>
<br>
Thanks,<br>
<br>
Nai Xia<br>
<br>
<br>
&gt;<br>
&gt; Ah, I&#39;d better send the patch separately as<br>
&gt; &quot;[PATCH] mm: fix race between mremap and removing migration entry=
&quot;:<br>
&gt; Pawel&#39;s &quot;l&quot; makes my old alpine setup choose quoted prin=
table when<br>
&gt; I reply to your mail.<br>
&gt;<br>
&gt; Hugh<br>
&gt;<br>
&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org=
</a>. =C2=A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www=
.linux-mm.org/</a> .<br>
&gt; Fight unfair telecom internet charges in Canada: sign <a href=3D"http:=
//stopthemeter.ca/" target=3D"_blank">http://stopthemeter.ca/</a><br>
&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvac=
k.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">emai=
l@kvack.org</a> &lt;/a&gt;<br>
&gt;<br>
</blockquote></div>

--20cf307f346ac1643804afbf3a56--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
