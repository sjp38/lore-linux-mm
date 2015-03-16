Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id F3E6E6B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 03:45:42 -0400 (EDT)
Received: by oier21 with SMTP id r21so30824393oie.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 00:45:42 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id m6si5056886oel.34.2015.03.16.00.45.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 00:45:42 -0700 (PDT)
Received: by oibu204 with SMTP id u204so30826834oib.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 00:45:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5502F9BC.2020001@redhat.com>
References: <CAB5gotvwyD74UugjB6XQ_v=o11Hu9wAuA6N94UvGObPARYEz0w@mail.gmail.com>
	<5502F9BC.2020001@redhat.com>
Date: Mon, 16 Mar 2015 00:45:42 -0700
Message-ID: <CAB5gotsXCiHiwnwg0vMOi1qS8FoUtUJfsaTSe0acYFYgoOUh=Q@mail.gmail.com>
Subject: Re: kswapd hogging in lowmem_shrink
From: Vaibhav Shinde <v.bhav.shinde@gmail.com>
Content-Type: multipart/alternative; boundary=001a114074407bce030511630947
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

--001a114074407bce030511630947
Content-Type: text/plain; charset=UTF-8

On Fri, Mar 13, 2015 at 7:52 AM, Rik van Riel <riel@redhat.com> wrote:
>
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
yes, lowmemorykiller kills the task depending on its oom_score, I am using
a embedded device with 2GB memory, there are task running that cause
lowmemory situation - no issue about it.

But my concern is kswapd takes too long to iterate through all the
processes(lowmem_shrink() => for_each_process()), the time taken is around
150msec, due to which my high priority application suffer system latency
that cause malfunctioning.

Thanks,
Vaibhav

--001a114074407bce030511630947
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br>On Fri, Mar 13, 2015 at 7:52 AM, Rik van Riel &lt;=
<a href=3D"mailto:riel@redhat.com">riel@redhat.com</a>&gt; wrote:<br>&gt;<b=
r>&gt; On 03/13/2015 10:25 AM, Vaibhav Shinde wrote:<br>&gt; &gt;<br>&gt; &=
gt; On low memory situation, I see various shrinkers being invoked, but in<=
br>&gt; &gt; lowmem_shrink() case, kswapd is found to be hogging for around=
 150msecs.<br>&gt; &gt;<br>&gt; &gt; Due to this my application suffer late=
ncy issue, as the cpu was not<br>&gt; &gt; released by kswapd0.<br>&gt; &gt=
;<br>&gt; &gt; I took below traces with vmscan events, that show lowmem_shr=
ink taking<br>&gt; &gt; such long time for execution.<br>&gt;<br>&gt; This =
is the Android low memory killer, which kills the<br>&gt; task with the low=
est priority in the system.<br>&gt;<br>&gt; The low memory killer will iter=
ate over all the tasks<br>&gt; in the system to identify the task to kill.<=
br>&gt;<br>&gt; This is not a problem in Android systems, and other<br>&gt;=
 small systems where this piece of code is used.<br>&gt;<br>&gt; What kind =
of system are you trying to use the low<br>&gt; memory killer on?<br>&gt;<b=
r>&gt; How many tasks are you running?<br>&gt;<br>yes, lowmemorykiller kill=
s the task depending on its oom_score, I am using a embedded device with 2G=
B memory, there are task running that cause lowmemory situation - no issue =
about it.<br><br>But my concern is kswapd takes too long to iterate through=
 all the processes(lowmem_shrink() =3D&gt; for_each_process()), the time ta=
ken is around 150msec, due to which my high priority application suffer sys=
tem latency that cause malfunctioning.<br><br>Thanks,<br>Vaibhav<br></div>

--001a114074407bce030511630947--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
