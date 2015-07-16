Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0902802FF
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 15:05:00 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so62315646ieb.1
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 12:05:00 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id 69si7225079iop.75.2015.07.16.12.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 12:04:59 -0700 (PDT)
Received: by igvi1 with SMTP id i1so20140477igv.1
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 12:04:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150716092841.GA2001@esperanza>
References: <cover.1436967694.git.vdavydov@parallels.com>
	<c6cbd44b9d5127cdaaa6f7d330e9bf715ec55534.1436967694.git.vdavydov@parallels.com>
	<CAJu=L58kZW2WRpx8wLx=FXdS29BJ+euLRdDcTXJKwf-VLT6SCA@mail.gmail.com>
	<20150716092841.GA2001@esperanza>
Date: Thu, 16 Jul 2015 12:04:59 -0700
Message-ID: <CAJu=L5_AUFv=Bh2WiWwOsMx41z_X0cAum_WkNikSE4Bo0r+wfQ@mail.gmail.com>
Subject: Re: [PATCH -mm v8 4/7] proc: add kpagecgroup file
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: multipart/alternative; boundary=089e0118260872eeb3051b02bf64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

--089e0118260872eeb3051b02bf64
Content-Type: text/plain; charset=UTF-8

On Thu, Jul 16, 2015 at 2:28 AM, Vladimir Davydov <vdavydov@parallels.com>
wrote:

> On Wed, Jul 15, 2015 at 12:03:18PM -0700, Andres Lagar-Cavilla wrote:
> > For both /proc/kpage* interfaces you add (and more critically for the
> > rmap-causing one, kpageidle):
> >
> > It's a good idea to do cond_sched(). Whether after each pfn, each Nth
> > pfn, each put_user, I leave to you, but a reasonable cadence is
> > needed, because user-space can call this on the entire physical
> > address space, and that's a lot of work to do without re-scheduling.
>
> I really don't think it's necessary. These files can only be
> read/written by the root, who has plenty ways to kill the system anyway.
> The program that is allowed to read/write these files must be conscious
> and do it in batches of reasonable size. AFAICS the same reasoning
> already lays behind /proc/kpagecount and /proc/kpageflag, which also do
> not thrust the "right" batch size on their readers.
>

Beg to disagree. You're conflating intended use with system health. A
cond_sched() is a one-liner.

Andres

>
> Thanks,
> Vladimir
>



-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--089e0118260872eeb3051b02bf64
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Thu, Jul 16, 2015 at 2:28 AM, Vladimir Davydov <span dir=3D"ltr">&lt=
;<a href=3D"mailto:vdavydov@parallels.com" target=3D"_blank">vdavydov@paral=
lels.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span cl=
ass=3D"">On Wed, Jul 15, 2015 at 12:03:18PM -0700, Andres Lagar-Cavilla wro=
te:<br>
&gt; For both /proc/kpage* interfaces you add (and more critically for the<=
br>
&gt; rmap-causing one, kpageidle):<br>
&gt;<br>
&gt; It&#39;s a good idea to do cond_sched(). Whether after each pfn, each =
Nth<br>
&gt; pfn, each put_user, I leave to you, but a reasonable cadence is<br>
&gt; needed, because user-space can call this on the entire physical<br>
&gt; address space, and that&#39;s a lot of work to do without re-schedulin=
g.<br>
<br>
</span>I really don&#39;t think it&#39;s necessary. These files can only be=
<br>
read/written by the root, who has plenty ways to kill the system anyway.<br=
>
The program that is allowed to read/write these files must be conscious<br>
and do it in batches of reasonable size. AFAICS the same reasoning<br>
already lays behind /proc/kpagecount and /proc/kpageflag, which also do<br>
not thrust the &quot;right&quot; batch size on their readers.<br></blockquo=
te><div><br></div><div>Beg to disagree. You&#39;re conflating intended use =
with system health. A cond_sched() is a one-liner.</div><div><br></div><div=
>Andres=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 =
.8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
Thanks,<br>
Vladimir<br>
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
</div></div>

--089e0118260872eeb3051b02bf64--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
