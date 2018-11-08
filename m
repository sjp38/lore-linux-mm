Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5436B05EF
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 07:26:46 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id z10so2523107lfe.21
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 04:26:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 96-v6sor2400270lja.27.2018.11.08.04.26.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 04:26:43 -0800 (PST)
MIME-Version: 1.0
References: <1530853846-30215-1-git-send-email-ks77sj@gmail.com> <CAMJBoFPGZ_pYFQTXb06U4QxM1ibUhmdxr6efwZigXdUo=4S=Vw@mail.gmail.com>
In-Reply-To: <CAMJBoFPGZ_pYFQTXb06U4QxM1ibUhmdxr6efwZigXdUo=4S=Vw@mail.gmail.com>
From: =?UTF-8?B?6rmA7KKF7ISd?= <ks77sj@gmail.com>
Date: Thu, 8 Nov 2018 21:26:33 +0900
Message-ID: <CALbL15baEnAXpsatY-LfA=V0_cHeiDHurke0DwpMUBmCedUQbA@mail.gmail.com>
Subject: Re: [PATCH] z3fold: fix wrong handling of headless pages
Content-Type: multipart/alternative; boundary="000000000000f1ffdf057a26581c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

--000000000000f1ffdf057a26581c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Vitaly,
thank you for the reply.

I agree your a new solution is more comprehensive and drop my patch is
simple way.
But, I think it's not fair.
If my previous patch was not wrong, is (my patch -> your patch) the right
way?

Best regards,
Jongseok

> 2018=EB=85=84 11=EC=9B=94 6=EC=9D=BC (=ED=99=94) =EC=98=A4=ED=9B=84 4:48,=
 Vitaly Wool <vitalywool@gmail.com>=EB=8B=98=EC=9D=B4 =EC=9E=91=EC=84=B1:
> Hi Jongseok,

> thank you for your work, we've now got a more comprehensive solution:
> https://lkml.org/lkml/2018/11/5/726

> Would you please confirm that it works for you? Also, would you be
>okay with dropping your patch in favor of the new one?

> ~Vitaly

--000000000000f1ffdf057a26581c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div>Hi=
 Vitaly,</div><div dir=3D"ltr">thank you for the reply.<br></div><div dir=
=3D"ltr"><br></div>I agree your a new solution is more comprehensive and dr=
op my patch is simple way.<div>But, I think it&#39;s not fair.</div><div>If=
 my previous patch was not wrong, is (my patch -&gt; your patch) the right =
way?</div><div><br></div><div>Best regards,</div><div>Jongseok</div><div><d=
iv><br><div class=3D"gmail_quote"><div dir=3D"ltr">&gt; 2018=EB=85=84 11=EC=
=9B=94 6=EC=9D=BC (=ED=99=94) =EC=98=A4=ED=9B=84 4:48, Vitaly Wool &lt;<a h=
ref=3D"mailto:vitalywool@gmail.com">vitalywool@gmail.com</a>&gt;=EB=8B=98=
=EC=9D=B4 =EC=9E=91=EC=84=B1:<br></div><div dir=3D"ltr">&gt; Hi Jongseok,<b=
r><br>&gt; thank you for your work, we&#39;ve now got a more comprehensive =
solution:<br>&gt;=C2=A0<a href=3D"https://lkml.org/lkml/2018/11/5/726" rel=
=3D"noreferrer" target=3D"_blank">https://lkml.org/lkml/2018/11/5/726</a><b=
r><br>&gt; Would you please confirm that it works for you? Also, would you =
be<br>&gt;okay with dropping your patch in favor of the new one?<br><br>&gt=
; ~Vitaly<br></div></div></div></div></div></div></div></div>

--000000000000f1ffdf057a26581c--
