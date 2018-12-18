Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id F06738E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 08:34:35 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id t13so9504059otk.4
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 05:34:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s126sor1419683oig.2.2018.12.18.05.34.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 05:34:34 -0800 (PST)
MIME-Version: 1.0
References: <1545104531-30658-1-git-send-email-gchen.guomin@gmail.com> <20181218124710.GU10600@bombadil.infradead.org>
In-Reply-To: <20181218124710.GU10600@bombadil.infradead.org>
From: gchen chen <gchen.guomin@gmail.com>
Date: Tue, 18 Dec 2018 21:34:23 +0800
Message-ID: <CAEEwsfT7CzG9nx69CQnaSYF2xgcN=aqbV3DpWfzx3gXDNS7_eg@mail.gmail.com>
Subject: Re: [PATCH] Export mm_update_next_owner function for unuse_mm.
Content-Type: multipart/alternative; boundary="00000000000048682a057d4bf5ba"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, gchen <guominchen@tencent.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--00000000000048682a057d4bf5ba
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Yes, I don't need to EXPORT this symbol again.
i have modified this patch and re-committed it.  The email link is :
https://lkml.org/lkml/2018/12/18/8
this patch you see is old.

thanks and regards

Matthew Wilcox <willy@infradead.org> =E4=BA=8E2018=E5=B9=B412=E6=9C=8818=E6=
=97=A5=E5=91=A8=E4=BA=8C =E4=B8=8B=E5=8D=888:47=E5=86=99=E9=81=93=EF=BC=9A

> On Tue, Dec 18, 2018 at 11:42:11AM +0800, gchen.guomin@gmail.com wrote:
> > +EXPORT_SYMBOL(mm_update_next_owner);
>
> Unless you've figured out how to build mmu_context.c as a module, you
> don't need to EXPORT the symbol.  Just the below hunk is enough.
>
> > diff --git a/mm/mmu_context.c b/mm/mmu_context.c
> > index 3e612ae..9eb81aa 100644
> > --- a/mm/mmu_context.c
> > +++ b/mm/mmu_context.c
> > @@ -60,5 +60,6 @@ void unuse_mm(struct mm_struct *mm)
> >       /* active_mm is still 'mm' */
> >       enter_lazy_tlb(mm, tsk);
> >       task_unlock(tsk);
> > +     mm_update_next_owner(mm);
> >  }
> >  EXPORT_SYMBOL_GPL(unuse_mm);
> > --
> > 1.8.3.1
> >
>

--00000000000048682a057d4bf5ba
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div>Yes, I don&#39;t ne=
ed to EXPORT this symbol again.=C2=A0</div><div>i have modified this patch =
and re-committed it.=C2=A0 The email link is :<a href=3D"https://lkml.org/l=
kml/2018/12/18/8">https://lkml.org/lkml/2018/12/18/8</a></div><div>this pat=
ch you see is old.=C2=A0</div><div><br></div><div>thanks and regards<br></d=
iv><div><div><br><div class=3D"gmail_quote"><div dir=3D"ltr">Matthew Wilcox=
 &lt;<a href=3D"mailto:willy@infradead.org" target=3D"_blank">willy@infrade=
ad.org</a>&gt; =E4=BA=8E2018=E5=B9=B412=E6=9C=8818=E6=97=A5=E5=91=A8=E4=BA=
=8C =E4=B8=8B=E5=8D=888:47=E5=86=99=E9=81=93=EF=BC=9A<br></div><blockquote =
class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px sol=
id rgb(204,204,204);padding-left:1ex">On Tue, Dec 18, 2018 at 11:42:11AM +0=
800, <a href=3D"mailto:gchen.guomin@gmail.com" target=3D"_blank">gchen.guom=
in@gmail.com</a> wrote:<br>
&gt; +EXPORT_SYMBOL(mm_update_next_owner);<br>
<br>
Unless you&#39;ve figured out how to build mmu_context.c as a module, you<b=
r>
don&#39;t need to EXPORT the symbol.=C2=A0 Just the below hunk is enough.<b=
r>
<br>
&gt; diff --git a/mm/mmu_context.c b/mm/mmu_context.c<br>
&gt; index 3e612ae..9eb81aa 100644<br>
&gt; --- a/mm/mmu_context.c<br>
&gt; +++ b/mm/mmu_context.c<br>
&gt; @@ -60,5 +60,6 @@ void unuse_mm(struct mm_struct *mm)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/* active_mm is still &#39;mm&#39; */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0enter_lazy_tlb(mm, tsk);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0task_unlock(tsk);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0mm_update_next_owner(mm);<br>
&gt;=C2=A0 }<br>
&gt;=C2=A0 EXPORT_SYMBOL_GPL(unuse_mm);<br>
&gt; -- <br>
&gt; 1.8.3.1<br>
&gt; <br>
</blockquote></div></div></div></div></div></div>

--00000000000048682a057d4bf5ba--
