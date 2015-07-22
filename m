Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id A70566B0253
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 16:46:22 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so176440078ieb.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 13:46:22 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id v89si2499501ioi.148.2015.07.22.13.46.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 13:46:22 -0700 (PDT)
Received: by igbij6 with SMTP id ij6so146244946igb.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 13:46:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150722124421.3313e8f007d76b386e1d61ec@linux-foundation.org>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<4c1eb396150ee14d7c3abf1a6f36ec8cc9dd9435.1437303956.git.vdavydov@parallels.com>
	<20150721163500.528bd39bbbc71abc3c8d429b@linux-foundation.org>
	<20150722162528.GN23374@esperanza>
	<20150722124421.3313e8f007d76b386e1d61ec@linux-foundation.org>
Date: Wed, 22 Jul 2015 13:46:21 -0700
Message-ID: <CAJu=L5-QKjd8ZjsUY8xrrtVB0k=aK5HSQAvscmqRjoJapj3_-A@mail.gmail.com>
Subject: Re: [PATCH -mm v9 7/8] proc: export idle flag via kpageflags
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: multipart/alternative; boundary=089e01182608090315051b7cdd29
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

--089e01182608090315051b7cdd29
Content-Type: text/plain; charset=UTF-8

In page_referenced_one:

+       if (referenced)
+               clear_page_idle(page);

Andres

On Wed, Jul 22, 2015 at 12:44 PM, Andrew Morton <akpm@linux-foundation.org>
wrote:

> On Wed, 22 Jul 2015 19:25:28 +0300 Vladimir Davydov <
> vdavydov@parallels.com> wrote:
>
> > On Tue, Jul 21, 2015 at 04:35:00PM -0700, Andrew Morton wrote:
> > > On Sun, 19 Jul 2015 15:31:16 +0300 Vladimir Davydov <
> vdavydov@parallels.com> wrote:
> > >
> > > > As noted by Minchan, a benefit of reading idle flag from
> > > > /proc/kpageflags is that one can easily filter dirty and/or
> unevictable
> > > > pages while estimating the size of unused memory.
> > > >
> > > > Note that idle flag read from /proc/kpageflags may be stale in case
> the
> > > > page was accessed via a PTE, because it would be too costly to
> iterate
> > > > over all page mappings on each /proc/kpageflags read to provide an
> > > > up-to-date value. To make sure the flag is up-to-date one has to read
> > > > /proc/kpageidle first.
> > >
> > > Is there any value in teaching the regular old page scanner to update
> > > these flags?  If it's doing an rmap scan anyway...
> >
> > I don't understand what you mean by "regular old page scanner". Could
> > you please elaborate?
>
> Whenever kswapd or direct reclaim perform an rmap scan, take that as an
> opportunity to also update PageIdle().
>
>


-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--089e01182608090315051b7cdd29
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">In page_referenced_one:<div><br></div><div><span style=3D"=
font-size:12.8000001907349px">+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (referenced)</=
span><br style=3D"font-size:12.8000001907349px"><span style=3D"font-size:12=
.8000001907349px">+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0c=
lear_page_idle(page);</span><br></div><div><span style=3D"font-size:12.8000=
001907349px"><br></span></div><div><span style=3D"font-size:12.800000190734=
9px">Andres</span></div></div><div class=3D"gmail_extra"><br><div class=3D"=
gmail_quote">On Wed, Jul 22, 2015 at 12:44 PM, Andrew Morton <span dir=3D"l=
tr">&lt;<a href=3D"mailto:akpm@linux-foundation.org" target=3D"_blank">akpm=
@linux-foundation.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x"><span class=3D"">On Wed, 22 Jul 2015 19:25:28 +0300 Vladimir Davydov &lt=
;<a href=3D"mailto:vdavydov@parallels.com">vdavydov@parallels.com</a>&gt; w=
rote:<br>
<br>
&gt; On Tue, Jul 21, 2015 at 04:35:00PM -0700, Andrew Morton wrote:<br>
&gt; &gt; On Sun, 19 Jul 2015 15:31:16 +0300 Vladimir Davydov &lt;<a href=
=3D"mailto:vdavydov@parallels.com">vdavydov@parallels.com</a>&gt; wrote:<br=
>
&gt; &gt;<br>
&gt; &gt; &gt; As noted by Minchan, a benefit of reading idle flag from<br>
&gt; &gt; &gt; /proc/kpageflags is that one can easily filter dirty and/or =
unevictable<br>
&gt; &gt; &gt; pages while estimating the size of unused memory.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Note that idle flag read from /proc/kpageflags may be stale =
in case the<br>
&gt; &gt; &gt; page was accessed via a PTE, because it would be too costly =
to iterate<br>
&gt; &gt; &gt; over all page mappings on each /proc/kpageflags read to prov=
ide an<br>
&gt; &gt; &gt; up-to-date value. To make sure the flag is up-to-date one ha=
s to read<br>
&gt; &gt; &gt; /proc/kpageidle first.<br>
&gt; &gt;<br>
&gt; &gt; Is there any value in teaching the regular old page scanner to up=
date<br>
&gt; &gt; these flags?=C2=A0 If it&#39;s doing an rmap scan anyway...<br>
&gt;<br>
&gt; I don&#39;t understand what you mean by &quot;regular old page scanner=
&quot;. Could<br>
&gt; you please elaborate?<br>
<br>
</span>Whenever kswapd or direct reclaim perform an rmap scan, take that as=
 an<br>
opportunity to also update PageIdle().<br>
<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br><div class=
=3D"gmail_signature"><div dir=3D"ltr"><span style=3D"color:rgb(85,85,85);fo=
nt-family:sans-serif;font-size:small;line-height:19.5px;border-width:2px 0p=
x 0px;border-style:solid;border-color:rgb(213,15,37);padding-top:2px;margin=
-top:2px">Andres Lagar-Cavilla=C2=A0|</span><span style=3D"color:rgb(85,85,=
85);font-family:sans-serif;font-size:small;line-height:19.5px;border-width:=
2px 0px 0px;border-style:solid;border-color:rgb(51,105,232);padding-top:2px=
;margin-top:2px">=C2=A0Google Kernel Team |</span><span style=3D"color:rgb(=
85,85,85);font-family:sans-serif;font-size:small;line-height:19.5px;border-=
width:2px 0px 0px;border-style:solid;border-color:rgb(0,153,57);padding-top=
:2px;margin-top:2px">=C2=A0<a href=3D"mailto:andreslc@google.com" target=3D=
"_blank">andreslc@google.com</a>=C2=A0</span><br></div></div>
</div>

--089e01182608090315051b7cdd29--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
