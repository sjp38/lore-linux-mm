Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30D716B025E
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 04:16:21 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id x190so260048346qkb.5
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:16:21 -0800 (PST)
Received: from mail-qt0-x22f.google.com (mail-qt0-x22f.google.com. [2607:f8b0:400d:c0d::22f])
        by mx.google.com with ESMTPS id i7si8463682qtf.245.2016.12.05.01.16.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 01:16:20 -0800 (PST)
Received: by mail-qt0-x22f.google.com with SMTP id c47so307909983qtc.2
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:16:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161205070519.GA30765@dhcp22.suse.cz>
References: <CAGDaZ_r3-DxOEsGdE2y1UsS_-=UR-Qc0CsouGtcCgoXY3kVotQ@mail.gmail.com>
 <20161205070519.GA30765@dhcp22.suse.cz>
From: Raymond Jennings <shentino@gmail.com>
Date: Mon, 5 Dec 2016 01:15:39 -0800
Message-ID: <CAGDaZ_oXcWVVAugGetVV2qBR9kJ-=VKKn8A0ErT-0vXOAZ6NTg@mail.gmail.com>
Subject: Re: Silly question about dethrottling
Content-Type: multipart/alternative; boundary=001a113f4d72a375d00542e5bd32
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

--001a113f4d72a375d00542e5bd32
Content-Type: text/plain; charset=UTF-8

On Sun, Dec 4, 2016 at 11:05 PM, Michal Hocko <mhocko@kernel.org> wrote:

> On Sun 04-12-16 13:56:54, Raymond Jennings wrote:
> > I have an application that is generating HUGE amounts of dirty data.
> > Multiple GiB worth, and I'd like to allow it to fill at least half of my
> > RAM.
>
> Could you be more specific why and what kind of problem you are trying
> to solve?
>
> > I already have /proc/sys/vm/dirty_ratio pegged at 80 and the background
> one
> > pegged at 50.  RAM is 32GiB.
>
> There is also dirty_bytes alternative which is an absolute numer.
>

How does this compare to setting dirty_ratio to a high percentage?

>
> > it appears to be butting heads with clean memory.  How do I tell my
> system
> > to prefer using RAM to soak up writes instead of caching?
>
> I am not sure I understand. Could you be more specific about what is the
> actual problem? Is it possible that your dirty data is already being
> flushed and that is wy you see a clean cache?
>

What I'm wanting is for my writing process not to get throttled, even when
the dirty memory it starts creating starts hogging memory the system would
rather use for cache.

--001a113f4d72a375d00542e5bd32
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On S=
un, Dec 4, 2016 at 11:05 PM, Michal Hocko <span dir=3D"ltr">&lt;<a href=3D"=
mailto:mhocko@kernel.org" target=3D"_blank">mhocko@kernel.org</a>&gt;</span=
> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Sun 04-12-16=
 13:56:54, Raymond Jennings wrote:<br>
&gt; I have an application that is generating HUGE amounts of dirty data.<b=
r>
&gt; Multiple GiB worth, and I&#39;d like to allow it to fill at least half=
 of my<br>
&gt; RAM.<br>
<br>
</span>Could you be more specific why and what kind of problem you are tryi=
ng<br>
to solve?<br>
<span class=3D""><br>
&gt; I already have /proc/sys/vm/dirty_ratio pegged at 80 and the backgroun=
d one<br>
&gt; pegged at 50.=C2=A0 RAM is 32GiB.<br>
<br>
</span>There is also dirty_bytes alternative which is an absolute numer.<br=
></blockquote><div><br></div><div>How does this compare to setting dirty_ra=
tio to a high percentage?=C2=A0</div><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<span class=3D""><br>
&gt; it appears to be butting heads with clean memory.=C2=A0 How do I tell =
my system<br>
&gt; to prefer using RAM to soak up writes instead of caching?<br>
<br>
</span>I am not sure I understand. Could you be more specific about what is=
 the<br>
actual problem? Is it possible that your dirty data is already being<br>
flushed and that is wy you see a clean cache?<br></blockquote><div><br></di=
v><div>What I&#39;m wanting is for my writing process not to get throttled,=
 even when the dirty memory it starts creating starts hogging memory the sy=
stem would rather use for cache.</div><div><br></div></div></div></div>

--001a113f4d72a375d00542e5bd32--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
