Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC126B000D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 17:30:17 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c6-v6so2898019qta.6
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 14:30:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h10-v6sor398784qvf.96.2018.08.08.14.30.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 14:30:16 -0700 (PDT)
MIME-Version: 1.0
References: <1531727262-11520-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726070355.GD8477@rapoport-lnx> <20180726172005.pgjmkvwz2lpflpor@pburton-laptop>
 <CAMPMW8p092oXk1w+SVjgx-ZH+46piAY8xgYPDfLUwLCkBm-TVw@mail.gmail.com> <20180802115550.GA10232@rapoport-lnx>
In-Reply-To: <20180802115550.GA10232@rapoport-lnx>
From: "Fancer's opinion" <fancer.lancer@gmail.com>
Date: Thu, 9 Aug 2018 00:30:03 +0300
Message-ID: <CAMPMW8qq-aEm-0dQrWh08SBBSRp3xAqR1PL5Oe-RvkJgUk6LjA@mail.gmail.com>
Subject: Re: [PATCH] mips: switch to NO_BOOTMEM
Content-Type: multipart/alternative; boundary="0000000000006d16e30572f33789"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Paul Burton <Paul.Burton@mips.com>, Linux-MIPS <linux-mips@linux-mips.org>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

--0000000000006d16e30572f33789
Content-Type: text/plain; charset="UTF-8"

Hello Mike,
I haven't read your patch text yet. I am waiting for the subsystem
maintainers response at least
about the necessity to have this type of changes being merged into the
sources (I mean
memblock/no-bootmem alteration). If they find it pointless (although I
would strongly disagree), then
nothing to discuss. Otherwise we can come up with a solution.

-Sergey


On Thu, Aug 2, 2018 at 2:56 PM Mike Rapoport <rppt@linux.vnet.ibm.com>
wrote:

> Hi,
>
> On Thu, Jul 26, 2018 at 10:55:53PM +0300, Fancer's opinion wrote:
> > Hello, folks
> > Regarding the no_bootmem patchset I've sent earlier.
> > I'm terribly sorry about huge delay with response. I got sucked in a new
> > project, so just didn't have a time to proceed with the series, answer
> to the
> > questions and resend the set.
> > If it is still relevant and needed for community, I can get back to the
> series
> > on the next week, answer to the Mett's questions (sorry, man, for doing
> it so
> > long), rebase it on top of the kernel 4.18 and resend the new version.
> We also
> > can try to combine it with this patch, if it is found convenient.
>
> So, what would be the best way to move forward?
>
> > Regards,
> > -Sergey
> >
> >
> > On Thu, 26 Jul 2018, 20:20 Paul Burton, <paul.burton@mips.com> wrote:
> >
> >     Hi Mike,
> >
> >     On Thu, Jul 26, 2018 at 10:03:56AM +0300, Mike Rapoport wrote:
> >     > Any comments on this?
> >
> >     I haven't looked at this in detail yet, but there was a much larger
> >     series submitted to accomplish this not too long ago, which needed
> >     another revision:
> >
> >
> https://patchwork.linux-mips.org/project/linux-mips/list/?series=787&
> >     state=*
> >
> >     Given that, I'd be (pleasantly) surprised if this one smaller patch
> is
> >     enough.
> >
> >     Thanks,
> >         Paul
> >
>
> --
> Sincerely yours,
> Mike.
>
>

--0000000000006d16e30572f33789
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello Mike,<br><div>I haven&#39;t read your patch text yet=
. I am waiting for the subsystem maintainers response at least</div><div>ab=
out the necessity to have this type of changes being merged into the source=
s (I mean</div><div>memblock/no-bootmem alteration). If they find it pointl=
ess (although I would strongly disagree), then</div><div>nothing to discuss=
. Otherwise we can come up with a solution.=C2=A0=C2=A0</div><div><br></div=
><div>-Sergey<br><div><br></div></div></div><br><div class=3D"gmail_quote">=
<div dir=3D"ltr">On Thu, Aug 2, 2018 at 2:56 PM Mike Rapoport &lt;<a href=
=3D"mailto:rppt@linux.vnet.ibm.com">rppt@linux.vnet.ibm.com</a>&gt; wrote:<=
br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex">Hi,<br>
<br>
On Thu, Jul 26, 2018 at 10:55:53PM +0300, Fancer&#39;s opinion wrote:<br>
&gt; Hello, folks<br>
&gt; Regarding the no_bootmem patchset I&#39;ve sent earlier.<br>
&gt; I&#39;m terribly sorry about huge delay with response. I got sucked in=
 a new<br>
&gt; project, so just didn&#39;t have a time to proceed with the series, an=
swer to the<br>
&gt; questions and resend the set.<br>
&gt; If it is still relevant and needed for community, I can get back to th=
e series<br>
&gt; on the next week, answer to the Mett&#39;s questions (sorry, man, for =
doing it so<br>
&gt; long), rebase it on top of the kernel 4.18 and resend the new version.=
 We also<br>
&gt; can try to combine it with this patch, if it is found convenient.<br>
<br>
So, what would be the best way to move forward?<br>
<br>
&gt; Regards,<br>
&gt; -Sergey<br>
&gt; <br>
&gt; <br>
&gt; On Thu, 26 Jul 2018, 20:20 Paul Burton, &lt;<a href=3D"mailto:paul.bur=
ton@mips.com" target=3D"_blank">paul.burton@mips.com</a>&gt; wrote:<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0Hi Mike,<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0On Thu, Jul 26, 2018 at 10:03:56AM +0300, Mike Rapo=
port wrote:<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; Any comments on this?<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0I haven&#39;t looked at this in detail yet, but the=
re was a much larger<br>
&gt;=C2=A0 =C2=A0 =C2=A0series submitted to accomplish this not too long ag=
o, which needed<br>
&gt;=C2=A0 =C2=A0 =C2=A0another revision:<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0 <a href=3D"https://patchwork.linux-mi=
ps.org/project/linux-mips/list/?series=3D787&amp;" rel=3D"noreferrer" targe=
t=3D"_blank">https://patchwork.linux-mips.org/project/linux-mips/list/?seri=
es=3D787&amp;</a><br>
&gt;=C2=A0 =C2=A0 =C2=A0state=3D*<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0Given that, I&#39;d be (pleasantly) surprised if th=
is one smaller patch is<br>
&gt;=C2=A0 =C2=A0 =C2=A0enough.<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0Thanks,<br>
&gt;=C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0 Paul<br>
&gt; <br>
<br>
-- <br>
Sincerely yours,<br>
Mike.<br>
<br>
</blockquote></div>

--0000000000006d16e30572f33789--
