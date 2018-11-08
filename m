Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7B76B0676
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 17:33:33 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id l18so1770255lfh.2
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 14:33:33 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r16-v6sor3585192ljr.41.2018.11.08.14.33.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 14:33:31 -0800 (PST)
MIME-Version: 1.0
References: <CAMJBoFP3C5NffHf2bPaY-W2qXPLs6z+Ker+Z+Sq_3MHV5xekHQ@mail.gmail.com>
 <20181108134540.12756-1-ks77sj@gmail.com> <20181108142312.f5efdc72ca0d64dc80046c92@linux-foundation.org>
In-Reply-To: <20181108142312.f5efdc72ca0d64dc80046c92@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Thu, 8 Nov 2018 23:33:17 +0100
Message-ID: <CAMJBoFM+_HJtZ3jxfxqXkYE+gw3wuBT6OunFaVZkw28boHKyCg@mail.gmail.com>
Subject: Re: [PATCH] z3fold: fix wrong handling of headless pages
Content-Type: multipart/alternative; boundary="000000000000f89205057a2ed2fe"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?B?6rmA7KKF7ISd?= <ks77sj@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

--000000000000f89205057a2ed2fe
Content-Type: text/plain; charset="UTF-8"

On Thu, Nov 8, 2018, 11:23 PM Andrew Morton <akpm@linux-foundation.org
wrote:

> On Thu,  8 Nov 2018 22:45:40 +0900 Jongseok Kim <ks77sj@gmail.com> wrote:
>
> > Yes, you are right.
> > I think that's the best way to deal it.
> > Thank you.
>
>
> I did this:
>
> Link:
> http://lkml.kernel.org/r/20181105162225.74e8837d03583a9b707cf559@gmail.com
> Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
> Signed-off-by: Jongseok Kim <ks77sj@gmail.com>
> Reported-by-by: Jongseok Kim <ks77sj@gmail.com>
> Reviewed-by: Snild Dolkow <snild@sony.com>
>

Thanks!

~Vitaly

>

--000000000000f89205057a2ed2fe
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">=
On Thu, Nov 8, 2018, 11:23 PM Andrew Morton &lt;<a href=3D"mailto:akpm@linu=
x-foundation.org">akpm@linux-foundation.org</a> wrote:<br></div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex">On Thu,=C2=A0 8 Nov 2018 22:45:40 +0900 Jongseok Kim &l=
t;<a href=3D"mailto:ks77sj@gmail.com" target=3D"_blank" rel=3D"noreferrer">=
ks77sj@gmail.com</a>&gt; wrote:<br>
<br>
&gt; Yes, you are right.<br>
&gt; I think that&#39;s the best way to deal it.<br>
&gt; Thank you.<br>
<br>
<br>
I did this:<br>
<br>
Link: <a href=3D"http://lkml.kernel.org/r/20181105162225.74e8837d03583a9b70=
7cf559@gmail.com" rel=3D"noreferrer noreferrer" target=3D"_blank">http://lk=
ml.kernel.org/r/20181105162225.74e8837d03583a9b707cf559@gmail.com</a><br>
Signed-off-by: Vitaly Wool &lt;<a href=3D"mailto:vitaly.vul@sony.com" targe=
t=3D"_blank" rel=3D"noreferrer">vitaly.vul@sony.com</a>&gt;<br>
Signed-off-by: Jongseok Kim &lt;<a href=3D"mailto:ks77sj@gmail.com" target=
=3D"_blank" rel=3D"noreferrer">ks77sj@gmail.com</a>&gt;<br>
Reported-by-by: Jongseok Kim &lt;<a href=3D"mailto:ks77sj@gmail.com" target=
=3D"_blank" rel=3D"noreferrer">ks77sj@gmail.com</a>&gt;<br>
Reviewed-by: Snild Dolkow &lt;<a href=3D"mailto:snild@sony.com" target=3D"_=
blank" rel=3D"noreferrer">snild@sony.com</a>&gt;<br></blockquote></div></di=
v><div dir=3D"auto"><br></div><div dir=3D"auto">Thanks!=C2=A0</div><div dir=
=3D"auto"><br></div><div dir=3D"auto">~Vitaly=C2=A0</div><div dir=3D"auto">=
<div class=3D"gmail_quote"><blockquote class=3D"gmail_quote" style=3D"margi=
n:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
</blockquote></div></div></div>

--000000000000f89205057a2ed2fe--
