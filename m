Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB8326B0008
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:56:02 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k21-v6so2140413qtj.23
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:56:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r126-v6sor1045654qkc.77.2018.07.26.12.56.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Jul 2018 12:56:01 -0700 (PDT)
MIME-Version: 1.0
References: <1531727262-11520-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726070355.GD8477@rapoport-lnx> <20180726172005.pgjmkvwz2lpflpor@pburton-laptop>
In-Reply-To: <20180726172005.pgjmkvwz2lpflpor@pburton-laptop>
From: "Fancer's opinion" <fancer.lancer@gmail.com>
Date: Thu, 26 Jul 2018 22:55:53 +0300
Message-ID: <CAMPMW8p092oXk1w+SVjgx-ZH+46piAY8xgYPDfLUwLCkBm-TVw@mail.gmail.com>
Subject: Re: [PATCH] mips: switch to NO_BOOTMEM
Content-Type: multipart/alternative; boundary="00000000000077705e0571ec627c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Burton <Paul.Burton@mips.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Linux-MIPS <linux-mips@linux-mips.org>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--00000000000077705e0571ec627c
Content-Type: text/plain; charset="UTF-8"

Hello, folks
Regarding the no_bootmem patchset I've sent earlier.
I'm terribly sorry about huge delay with response. I got sucked in a new
project, so just didn't have a time to proceed with the series, answer to
the questions and resend the set.
If it is still relevant and needed for community, I can get back to the
series on the next week, answer to the Mett's questions (sorry, man, for
doing it so long), rebase it on top of the kernel 4.18 and resend the new
version. We also can try to combine it with this patch, if it is found
convenient.

Regards,
-Sergey


On Thu, 26 Jul 2018, 20:20 Paul Burton, <paul.burton@mips.com> wrote:

> Hi Mike,
>
> On Thu, Jul 26, 2018 at 10:03:56AM +0300, Mike Rapoport wrote:
> > Any comments on this?
>
> I haven't looked at this in detail yet, but there was a much larger
> series submitted to accomplish this not too long ago, which needed
> another revision:
>
>
> https://patchwork.linux-mips.org/project/linux-mips/list/?series=787&state=*
>
> Given that, I'd be (pleasantly) surprised if this one smaller patch is
> enough.
>
> Thanks,
>     Paul
>

--00000000000077705e0571ec627c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">Hello, folks<div dir=3D"auto">Regarding the no_bootmem pa=
tchset I&#39;ve sent earlier.</div><div dir=3D"auto">I&#39;m terribly sorry=
 about huge delay with response. I got sucked in a new project, so just did=
n&#39;t have a time to proceed with the series, answer to the questions and=
 resend the set.</div><div dir=3D"auto">If it is still relevant and needed =
for community, I can get back to the series on the next week, answer to the=
 Mett&#39;s questions (sorry, man, for doing it so long), rebase it on top =
of the kernel 4.18 and resend the new version. We also can try to combine i=
t with this patch, if it is found convenient.</div><div dir=3D"auto"><br></=
div><div dir=3D"auto">Regards,</div><div dir=3D"auto">-Sergey</div><div dir=
=3D"auto"><br></div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr">O=
n Thu, 26 Jul 2018, 20:20 Paul Burton, &lt;<a href=3D"mailto:paul.burton@mi=
ps.com">paul.burton@mips.com</a>&gt; wrote:<br></div><blockquote class=3D"g=
mail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-l=
eft:1ex">Hi Mike,<br>
<br>
On Thu, Jul 26, 2018 at 10:03:56AM +0300, Mike Rapoport wrote:<br>
&gt; Any comments on this?<br>
<br>
I haven&#39;t looked at this in detail yet, but there was a much larger<br>
series submitted to accomplish this not too long ago, which needed<br>
another revision:<br>
<br>
=C2=A0 =C2=A0 <a href=3D"https://patchwork.linux-mips.org/project/linux-mip=
s/list/?series=3D787&amp;state=3D*" rel=3D"noreferrer noreferrer" target=3D=
"_blank">https://patchwork.linux-mips.org/project/linux-mips/list/?series=
=3D787&amp;state=3D*</a><br>
<br>
Given that, I&#39;d be (pleasantly) surprised if this one smaller patch is<=
br>
enough.<br>
<br>
Thanks,<br>
=C2=A0 =C2=A0 Paul<br>
</blockquote></div>

--00000000000077705e0571ec627c--
