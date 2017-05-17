Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6B396B02FA
	for <linux-mm@kvack.org>; Wed, 17 May 2017 13:23:45 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id p24so12275290ioi.8
        for <linux-mm@kvack.org>; Wed, 17 May 2017 10:23:45 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id y126si2834234iof.59.2017.05.17.10.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 10:23:45 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id d68so2198799ita.1
        for <linux-mm@kvack.org>; Wed, 17 May 2017 10:23:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d55eeeee-76ed-b171-d1df-643b36bb17b9@infradead.org>
References: <20170517133842.5733-1-mdeguzis@gmail.com> <d55eeeee-76ed-b171-d1df-643b36bb17b9@infradead.org>
From: mikey d <mdeguzis@gmail.com>
Date: Wed, 17 May 2017 13:23:44 -0400
Message-ID: <CAHwSjun=zC=ds=RsSyQwCWgaXhFkLxLrKYD+7i7+xfisRrPTCw@mail.gmail.com>
Subject: Re: [PATCH] Correct spelling and grammar for notification text
Content-Type: multipart/alternative; boundary="001a11419bfae44883054fbb8ce5"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-mm@kvack.org, trivial@kernel.org

--001a11419bfae44883054fbb8ce5
Content-Type: text/plain; charset="UTF-8"

V2 incoming soon. My first patch :)

On May 17, 2017 11:35, "Randy Dunlap" <rdunlap@infradead.org> wrote:

> On 05/17/17 06:38, Michael DeGuzis wrote:
> > From: professorkaos64 <mdeguzis@gmail.com>
> >
> > This patch fixes up some grammar and spelling in the information
> > block for huge_memory.c.
>
> Missing Signed-off-by: <real name and email address>
>
> > ---
> >  mm/huge_memory.c | 10 +++++-----
> >  1 file changed, 5 insertions(+), 5 deletions(-)
> >
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index a84909cf20d3..af137fc0ca09 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -38,12 +38,12 @@
> >  #include "internal.h"
> >
> >  /*
> > - * By default transparent hugepage support is disabled in order that
> avoid
> > - * to risk increase the memory footprint of applications without a
> guaranteed
> > - * benefit. When transparent hugepage support is enabled, is for all
> mappings,
> > - * and khugepaged scans all mappings.
> > + * By default, transparent hugepage support is disabled in order to
> avoid
> > + * risking an increased memory footprint for applications that are not
> > + * guaranteed to benefit from it. When transparent hugepage support is
> > + * enabled, it is for all mappings, and khugepaged scans all mappings.
> >   * Defrag is invoked by khugepaged hugepage allocations and by page
> faults
> > - * for all hugepage allocations.
> > + * for all hugepage allocations.
>
> Several of the new (+) patch lines end with a space character. Not good.
>
> >   */
> >  unsigned long transparent_hugepage_flags __read_mostly =
> >  #ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
> >
>
>
> --
> ~Randy
>

--001a11419bfae44883054fbb8ce5
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">V2 incoming soon. My first patch :)=C2=A0</div><div class=
=3D"gmail_extra"><br><div class=3D"gmail_quote">On May 17, 2017 11:35, &quo=
t;Randy Dunlap&quot; &lt;<a href=3D"mailto:rdunlap@infradead.org">rdunlap@i=
nfradead.org</a>&gt; wrote:<br type=3D"attribution"><blockquote class=3D"gm=
ail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-le=
ft:1ex">On 05/17/17 06:38, Michael DeGuzis wrote:<br>
&gt; From: professorkaos64 &lt;<a href=3D"mailto:mdeguzis@gmail.com">mdeguz=
is@gmail.com</a>&gt;<br>
&gt;<br>
&gt; This patch fixes up some grammar and spelling in the information<br>
&gt; block for huge_memory.c.<br>
<br>
Missing Signed-off-by: &lt;real name and email address&gt;<br>
<br>
&gt; ---<br>
&gt;=C2=A0 mm/huge_memory.c | 10 +++++-----<br>
&gt;=C2=A0 1 file changed, 5 insertions(+), 5 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/huge_memory.c b/mm/huge_memory.c<br>
&gt; index a84909cf20d3..af137fc0ca09 100644<br>
&gt; --- a/mm/huge_memory.c<br>
&gt; +++ b/mm/huge_memory.c<br>
&gt; @@ -38,12 +38,12 @@<br>
&gt;=C2=A0 #include &quot;internal.h&quot;<br>
&gt;<br>
&gt;=C2=A0 /*<br>
&gt; - * By default transparent hugepage support is disabled in order that =
avoid<br>
&gt; - * to risk increase the memory footprint of applications without a gu=
aranteed<br>
&gt; - * benefit. When transparent hugepage support is enabled, is for all =
mappings,<br>
&gt; - * and khugepaged scans all mappings.<br>
&gt; + * By default, transparent hugepage support is disabled in order to a=
void<br>
&gt; + * risking an increased memory footprint for applications that are no=
t<br>
&gt; + * guaranteed to benefit from it. When transparent hugepage support i=
s<br>
&gt; + * enabled, it is for all mappings, and khugepaged scans all mappings=
.<br>
&gt;=C2=A0 =C2=A0* Defrag is invoked by khugepaged hugepage allocations and=
 by page faults<br>
&gt; - * for all hugepage allocations.<br>
&gt; + * for all hugepage allocations.<br>
<br>
Several of the new (+) patch lines end with a space character. Not good.<br=
>
<br>
&gt;=C2=A0 =C2=A0*/<br>
&gt;=C2=A0 unsigned long transparent_hugepage_flags __read_mostly =3D<br>
&gt;=C2=A0 #ifdef CONFIG_TRANSPARENT_HUGEPAGE_<wbr>ALWAYS<br>
&gt;<br>
<br>
<br>
--<br>
~Randy<br>
</blockquote></div></div>

--001a11419bfae44883054fbb8ce5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
