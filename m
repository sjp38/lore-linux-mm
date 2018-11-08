Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC526B05F3
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 07:34:36 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id 69-v6so5997469ljs.4
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 04:34:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c7sor1126623lff.32.2018.11.08.04.34.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 04:34:34 -0800 (PST)
MIME-Version: 1.0
References: <1530853846-30215-1-git-send-email-ks77sj@gmail.com> <CAMJBoFPGZ_pYFQTXb06U4QxM1ibUhmdxr6efwZigXdUo=4S=Vw@mail.gmail.com>
In-Reply-To: <CAMJBoFPGZ_pYFQTXb06U4QxM1ibUhmdxr6efwZigXdUo=4S=Vw@mail.gmail.com>
From: =?UTF-8?B?6rmA7KKF7ISd?= <ks77sj@gmail.com>
Date: Thu, 8 Nov 2018 21:34:24 +0900
Message-ID: <CALbL15bGHL_M=ofWy_VrDZU_7b2DOC7BnpqJ63gfQ_1gNcG_9A@mail.gmail.com>
Subject: Re: [PATCH] z3fold: fix wrong handling of headless pages
Content-Type: multipart/alternative; boundary="00000000000003fea1057a2675c5"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

--00000000000003fea1057a2675c5
Content-Type: text/plain; charset="UTF-8"

Hi Vitaly,
thank you for the reply.

I agree your a new solution is more comprehensive and drop my patch is
simple way.
But, I think it's not fair.
If my previous patch was not wrong, is (my patch -> your patch) the right
way?

I'm sorry I sent reply twice.

Best regards,
Jongseok


> On 6/11/2018 4:48 PM, Vitaly Wool wrote:
> Hi Jongseok,

> thank you for your work, we've now got a more comprehensive solution:
> https://lkml.org/lkml/2018/11/5/726

> Would you please confirm that it works for you? Also, would you be
>okay with dropping your patch in favor of the new one?

> ~Vitaly

--00000000000003fea1057a2675c5
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div style=3D"color:rgb(0,0,0)">Hi Vitaly=
,</div><div dir=3D"ltr" style=3D"color:rgb(0,0,0)">thank you for the reply.=
<br></div><div dir=3D"ltr" style=3D"color:rgb(0,0,0)"><br></div><span style=
=3D"color:rgb(0,0,0)">I agree your a new solution is more comprehensive and=
 drop my patch is simple way.</span><div style=3D"color:rgb(0,0,0)">But, I =
think it&#39;s not fair.</div><div style=3D"color:rgb(0,0,0)">If my previou=
s patch was not wrong, is (my patch -&gt; your patch) the right way?</div><=
div style=3D"color:rgb(0,0,0)"><br></div><div><font color=3D"#000000">I&#39=
;m sorry I sent reply twice.</font><br></div><div><font color=3D"#000000"><=
br></font></div><div style=3D"color:rgb(0,0,0)">Best regards,</div><div sty=
le=3D"color:rgb(0,0,0)">Jongseok</div><div style=3D"color:rgb(0,0,0)"><br><=
/div><div style=3D"color:rgb(0,0,0)"><br></div><div style=3D"color:rgb(0,0,=
0)"><div class=3D"gmail_quote"><div dir=3D"ltr">&gt; On 6/11/2018 4:48 PM, =
Vitaly Wool wrote:<br></div><div dir=3D"ltr">&gt; Hi Jongseok,<div class=3D=
"gmail-adL"><span class=3D"gmail-im" style=3D"color:rgb(80,0,80)"><br>&gt; =
thank you for your work, we&#39;ve now got a more comprehensive solution:<b=
r>&gt;=C2=A0<a href=3D"https://lkml.org/lkml/2018/11/5/726" rel=3D"noreferr=
er" target=3D"_blank">https://lkml.org/lkml/2018/11/5/726</a><br><br>&gt; W=
ould you please confirm that it works for you? Also, would you be<br>&gt;ok=
ay with dropping your patch in favor of the new one?<br><br>&gt; ~Vitaly</s=
pan></div></div></div></div></div></div>

--00000000000003fea1057a2675c5--
