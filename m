Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 11D396B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 01:03:48 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id w62so4515801wes.5
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 22:03:48 -0700 (PDT)
Received: from mail-wg0-x22c.google.com (mail-wg0-x22c.google.com [2a00:1450:400c:c00::22c])
        by mx.google.com with ESMTPS id gi5si3019667wib.15.2014.04.27.22.03.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 27 Apr 2014 22:03:47 -0700 (PDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so5886401wgh.27
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 22:03:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140427114600.GA21935@gmail.com>
References: <535C854C.1070105@gmail.com>
	<20140427114600.GA21935@gmail.com>
Date: Mon, 28 Apr 2014 13:03:46 +0800
Message-ID: <CAKXJSOEB4seBWOjGyQ2ZvCxPNcb5rBfHOQP-jH3p_kJCa8EAUQ@mail.gmail.com>
Subject: Re: [PATCH] mm: update the comment for high_memory
From: Wang Sheng-Hui <shhuiw@gmail.com>
Content-Type: multipart/alternative; boundary=e89a8f5034f884a57e04f8133daa
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, peterz@infradead.org, riel@redhat.com, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

--e89a8f5034f884a57e04f8133daa
Content-Type: text/plain; charset=UTF-8

Got it, Ingo.

Will figure out more fine comment.


2014-04-27 19:46 GMT+08:00 Ingo Molnar <mingo@kernel.org>:

>
> * Wang Sheng-Hui <shhuiw@gmail.com> wrote:
>
> >
> > The system variable is not used for x86 only now. Remove the
> > "x86" strings.
> >
> > Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
> > ---
> >  mm/memory.c | 7 +++----
> >  1 file changed, 3 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 93e332d..1615a64 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -85,14 +85,13 @@ EXPORT_SYMBOL(mem_map);
> >  #endif
> >
> >  /*
> > - * A number of key systems in x86 including ioremap() rely on the
> assumption
> > - * that high_memory defines the upper bound on direct map memory, then
> end
> > - * of ZONE_NORMAL.  Under CONFIG_DISCONTIG this means that max_low_pfn
> and
> > + * A number of key systems including ioremap() rely on the assumption
> that
> > + * high_memory defines the upper bound on direct map memory, then end of
> > + * ZONE_NORMAL.  Under CONFIG_DISCONTIG this means that max_low_pfn and
> >   * highstart_pfn must be the same; there must be no gap between
> ZONE_NORMAL
> >   * and ZONE_HIGHMEM.
>
> ioremap() is not a 'key system', so if we are touching it then the
> comment should be fixed in other ways as well.
>
> Thanks,
>
>         Ingo
>

--e89a8f5034f884a57e04f8133daa
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Got it, Ingo.<br><br></div>Will figure out more fine =
comment.<br></div><div class=3D"gmail_extra"><br><br><div class=3D"gmail_qu=
ote">2014-04-27 19:46 GMT+08:00 Ingo Molnar <span dir=3D"ltr">&lt;<a href=
=3D"mailto:mingo@kernel.org" target=3D"_blank">mingo@kernel.org</a>&gt;</sp=
an>:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5"><br>
* Wang Sheng-Hui &lt;<a href=3D"mailto:shhuiw@gmail.com">shhuiw@gmail.com</=
a>&gt; wrote:<br>
<br>
&gt;<br>
&gt; The system variable is not used for x86 only now. Remove the<br>
&gt; &quot;x86&quot; strings.<br>
&gt;<br>
&gt; Signed-off-by: Wang Sheng-Hui &lt;<a href=3D"mailto:shhuiw@gmail.com">=
shhuiw@gmail.com</a>&gt;<br>
&gt; ---<br>
&gt; =C2=A0mm/memory.c | 7 +++----<br>
&gt; =C2=A01 file changed, 3 insertions(+), 4 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/memory.c b/mm/memory.c<br>
&gt; index 93e332d..1615a64 100644<br>
&gt; --- a/mm/memory.c<br>
&gt; +++ b/mm/memory.c<br>
&gt; @@ -85,14 +85,13 @@ EXPORT_SYMBOL(mem_map);<br>
&gt; =C2=A0#endif<br>
&gt;<br>
&gt; =C2=A0/*<br>
&gt; - * A number of key systems in x86 including ioremap() rely on the ass=
umption<br>
&gt; - * that high_memory defines the upper bound on direct map memory, the=
n end<br>
&gt; - * of ZONE_NORMAL. =C2=A0Under CONFIG_DISCONTIG this means that max_l=
ow_pfn and<br>
&gt; + * A number of key systems including ioremap() rely on the assumption=
 that<br>
&gt; + * high_memory defines the upper bound on direct map memory, then end=
 of<br>
&gt; + * ZONE_NORMAL. =C2=A0Under CONFIG_DISCONTIG this means that max_low_=
pfn and<br>
&gt; =C2=A0 * highstart_pfn must be the same; there must be no gap between =
ZONE_NORMAL<br>
&gt; =C2=A0 * and ZONE_HIGHMEM.<br>
<br>
</div></div>ioremap() is not a &#39;key system&#39;, so if we are touching =
it then the<br>
comment should be fixed in other ways as well.<br>
<br>
Thanks,<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 Ingo<br>
</blockquote></div><br></div>

--e89a8f5034f884a57e04f8133daa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
