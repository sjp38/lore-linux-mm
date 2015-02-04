Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id ABD8A6B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 22:56:57 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id l13so31904138iga.5
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 19:56:57 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id c13si746925igo.19.2015.02.03.19.56.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 19:56:57 -0800 (PST)
Received: by mail-ig0-f175.google.com with SMTP id hn18so31982452igb.2
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 19:56:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150203150408.1913cf209c4552683cca8b35@linux-foundation.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
	<1422985392-28652-3-git-send-email-a.ryabinin@samsung.com>
	<20150203150408.1913cf209c4552683cca8b35@linux-foundation.org>
Date: Wed, 4 Feb 2015 07:56:56 +0400
Message-ID: <CADmp3AN2pA68nA_DyaohEueBK_G2soYEnA_9Gb5hjLWP3xZSzQ@mail.gmail.com>
Subject: Re: [PATCH v11 02/19] Add kernel address sanitizer infrastructure.
From: Andrey Konovalov <adech.fo@gmail.com>
Content-Type: multipart/alternative; boundary=001a1140af42bf12b0050e3b2d4e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

--001a1140af42bf12b0050e3b2d4e
Content-Type: text/plain; charset=UTF-8

Sorry I didn't reply earlier.

Signed-off-by: Andrey Konovalov <adech.fo@gmail.com>

On Wed, Feb 4, 2015 at 2:04 AM, Andrew Morton <akpm@linux-foundation.org>
wrote:

> On Tue, 03 Feb 2015 20:42:55 +0300 Andrey Ryabinin <a.ryabinin@samsung.com>
> wrote:
>
> >
> > ...
> >
> > Based on work by Andrey Konovalov <adech.fo@gmail.com>
> >
>
> We still don't have Andrey Konovalov's signoff?  As it stands we're
> taking some of his work and putting it into Linux without his
> permission.
>
> > ...
> >
> > --- /dev/null
> > +++ b/mm/kasan/kasan.c
> > @@ -0,0 +1,302 @@
> > +/*
> > + * This file contains shadow memory manipulation code.
> > + *
> > + * Copyright (c) 2014 Samsung Electronics Co., Ltd.
> > + * Author: Andrey Ryabinin <a.ryabinin@samsung.com>
> > + *
> > + * Some of code borrowed from https://github.com/xairy/linux by
> > + *        Andrey Konovalov <adech.fo@gmail.com>
> > + *
> > + * This program is free software; you can redistribute it and/or modify
> > + * it under the terms of the GNU General Public License version 2 as
> > + * published by the Free Software Foundation.
> > + *
> > + */
>
> https://code.google.com/p/thread-sanitizer/ is BSD licensed and we're
> changing it to GPL.
>
> I don't do the lawyer stuff, but this is all a bit worrisome.  I'd be a
> lot more comfortable with that signed-off-by, please.
>
>
>


-- 
Sincerely,
Andrey Konovalov.

--001a1140af42bf12b0050e3b2d4e
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Sorry I didn&#39;t reply earlier.<div><br></div><div>Signe=
d-off-by: Andrey Konovalov &lt;<a href=3D"mailto:adech.fo@gmail.com">adech.=
fo@gmail.com</a>&gt;</div></div><div class=3D"gmail_extra"><br><div class=
=3D"gmail_quote">On Wed, Feb 4, 2015 at 2:04 AM, Andrew Morton <span dir=3D=
"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org" target=3D"_blank">ak=
pm@linux-foundation.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex">On Tue, 03 Feb 2015 20:42:55 +0300 Andrey Ryabinin &lt;<a href=3D"mail=
to:a.ryabinin@samsung.com">a.ryabinin@samsung.com</a>&gt; wrote:<br>
<br>
&gt;<br>
&gt; ...<br>
<span class=3D"">&gt;<br>
&gt; Based on work by Andrey Konovalov &lt;<a href=3D"mailto:adech.fo@gmail=
.com">adech.fo@gmail.com</a>&gt;<br>
&gt;<br>
<br>
</span>We still don&#39;t have Andrey Konovalov&#39;s signoff?=C2=A0 As it =
stands we&#39;re<br>
taking some of his work and putting it into Linux without his<br>
permission.<br>
<br>
&gt; ...<br>
<span class=3D"">&gt;<br>
&gt; --- /dev/null<br>
&gt; +++ b/mm/kasan/kasan.c<br>
&gt; @@ -0,0 +1,302 @@<br>
&gt; +/*<br>
&gt; + * This file contains shadow memory manipulation code.<br>
&gt; + *<br>
&gt; + * Copyright (c) 2014 Samsung Electronics Co., Ltd.<br>
&gt; + * Author: Andrey Ryabinin &lt;<a href=3D"mailto:a.ryabinin@samsung.c=
om">a.ryabinin@samsung.com</a>&gt;<br>
&gt; + *<br>
&gt; + * Some of code borrowed from <a href=3D"https://github.com/xairy/lin=
ux" target=3D"_blank">https://github.com/xairy/linux</a> by<br>
&gt; + *=C2=A0 =C2=A0 =C2=A0 =C2=A0 Andrey Konovalov &lt;<a href=3D"mailto:=
adech.fo@gmail.com">adech.fo@gmail.com</a>&gt;<br>
&gt; + *<br>
&gt; + * This program is free software; you can redistribute it and/or modi=
fy<br>
&gt; + * it under the terms of the GNU General Public License version 2 as<=
br>
&gt; + * published by the Free Software Foundation.<br>
&gt; + *<br>
&gt; + */<br>
<br>
</span><a href=3D"https://code.google.com/p/thread-sanitizer/" target=3D"_b=
lank">https://code.google.com/p/thread-sanitizer/</a> is BSD licensed and w=
e&#39;re<br>
changing it to GPL.<br>
<br>
I don&#39;t do the lawyer stuff, but this is all a bit worrisome.=C2=A0 I&#=
39;d be a<br>
lot more comfortable with that signed-off-by, please.<br>
<br>
<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br><div class=
=3D"gmail_signature"><div style=3D"text-align:left"><font color=3D"#111111"=
 face=3D"Helvetica Neue, Helvetica, Verdana, Arial, sans-serif"><span style=
=3D"line-height:18px">Sincerely,</span></font></div><div style=3D"text-alig=
n:left"><font color=3D"#111111" face=3D"Helvetica Neue, Helvetica, Verdana,=
 Arial, sans-serif"><span style=3D"line-height:18px">Andrey Konovalov.</spa=
n></font></div></div>
</div>

--001a1140af42bf12b0050e3b2d4e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
