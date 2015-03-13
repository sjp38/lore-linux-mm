Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id E38BF829BE
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 11:27:03 -0400 (EDT)
Received: by oifu20 with SMTP id u20so20190220oif.11
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 08:27:03 -0700 (PDT)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com. [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id ix8si1222449obc.59.2015.03.13.08.27.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 08:27:03 -0700 (PDT)
Received: by obcuz6 with SMTP id uz6so20414194obc.7
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 08:27:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5502F9BC.2020001@redhat.com>
References: <CAB5gotvwyD74UugjB6XQ_v=o11Hu9wAuA6N94UvGObPARYEz0w@mail.gmail.com>
	<5502F9BC.2020001@redhat.com>
Date: Fri, 13 Mar 2015 20:57:03 +0530
Message-ID: <CAB5gott45oWidv6hhzfHrvRp6xmxGqkJwJuHqCK6bzejKsW7iQ@mail.gmail.com>
Subject: Re: kswapd hogging in lowmem_shrink
From: Vaibhav Shinde <v.bhav.shinde@gmail.com>
Content-Type: multipart/alternative; boundary=001a1135e1eae1d04805112d21fc
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

--001a1135e1eae1d04805112d21fc
Content-Type: text/plain; charset=UTF-8

On Fri, Mar 13, 2015 at 8:22 PM, Rik van Riel <riel@redhat.com> wrote:

> On 03/13/2015 10:25 AM, Vaibhav Shinde wrote:
> >
> > On low memory situation, I see various shrinkers being invoked, but in
> > lowmem_shrink() case, kswapd is found to be hogging for around 150msecs.
> >
> > Due to this my application suffer latency issue, as the cpu was not
> > released by kswapd0.
> >
> > I took below traces with vmscan events, that show lowmem_shrink taking
> > such long time for execution.
>
> This is the Android low memory killer, which kills the
> task with the lowest priority in the system.
>
> The low memory killer will iterate over all the tasks
> in the system to identify the task to kill.
>
> This is not a problem in Android systems, and other
> small systems where this piece of code is used.
>
> What kind of system are you trying to use the low
> memory killer on?
>
> How many tasks are you running?
>
> yes, lowmemorykiller kills the task depending on its oom_score, I am using
a embedded device with 2GB memory, there are task running that cause
lowmemory situation - no issue about it.

But my concern is kswapd takes too long to iterate through all the
processes(lowmem_shrink() => for_each_process()), the time taken is around
150msec, due to which my high priority application suffer system latency
that cause malfunctioning.

--001a1135e1eae1d04805112d21fc
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On F=
ri, Mar 13, 2015 at 8:22 PM, Rik van Riel <span dir=3D"ltr">&lt;<a href=3D"=
mailto:riel@redhat.com" target=3D"_blank">riel@redhat.com</a>&gt;</span> wr=
ote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex=
;border-left-width:1px;border-left-color:rgb(204,204,204);border-left-style=
:solid;padding-left:1ex"><span class=3D"">On 03/13/2015 10:25 AM, Vaibhav S=
hinde wrote:<br>
&gt;<br>
&gt; On low memory situation, I see various shrinkers being invoked, but in=
<br>
&gt; lowmem_shrink() case, kswapd is found to be hogging for around 150msec=
s.<br>
&gt;<br>
&gt; Due to this my application suffer latency issue, as the cpu was not<br=
>
&gt; released by kswapd0.<br>
&gt;<br>
&gt; I took below traces with vmscan events, that show lowmem_shrink taking=
<br>
&gt; such long time for execution.<br>
<br>
</span>This is the Android low memory killer, which kills the<br>
task with the lowest priority in the system.<br>
<br>
The low memory killer will iterate over all the tasks<br>
in the system to identify the task to kill.<br>
<br>
This is not a problem in Android systems, and other<br>
small systems where this piece of code is used.<br>
<br>
What kind of system are you trying to use the low<br>
memory killer on?<br>
<br>
How many tasks are you running?<br>
<br>
</blockquote></div><div>yes, lowmemorykiller kills the task depending on it=
s oom_score, I am using a embedded device with 2GB memory, there are task r=
unning that cause lowmemory situation - no issue about it.</div><div><br></=
div><div>But my concern is kswapd takes too long to iterate through all the=
 processes(lowmem_shrink() =3D&gt; for_each_process()), the time taken is a=
round 150msec, due to which my high priority application suffer system late=
ncy that cause malfunctioning.</div></div></div>

--001a1135e1eae1d04805112d21fc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
