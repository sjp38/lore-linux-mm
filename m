Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2196B0035
	for <linux-mm@kvack.org>; Sun, 20 Apr 2014 14:35:42 -0400 (EDT)
Received: by mail-yh0-f47.google.com with SMTP id 29so2902676yhl.6
        for <linux-mm@kvack.org>; Sun, 20 Apr 2014 11:35:41 -0700 (PDT)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id v6si27161939yhm.170.2014.04.20.11.35.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 20 Apr 2014 11:35:40 -0700 (PDT)
Received: by mail-yk0-f176.google.com with SMTP id 19so2778933ykq.21
        for <linux-mm@kvack.org>; Sun, 20 Apr 2014 11:35:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140420142830.GC22077@alpha.arachsys.com>
References: <20140416154650.GA3034@alpha.arachsys.com>
	<20140418155939.GE4523@dhcp22.suse.cz>
	<5351679F.5040908@parallels.com>
	<20140420142830.GC22077@alpha.arachsys.com>
Date: Sun, 20 Apr 2014 11:35:40 -0700
Message-ID: <CAAAKZwvrj0TtK02s5X_T-ozpcRg3oow4jnevaRLiF1Wtk=_8rA@mail.gmail.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with kmem
 limit doesn't recover after disk i/o causes limit to be hit]
From: Tim Hockin <thockin@hockin.org>
Content-Type: multipart/alternative; boundary=001a1133d9665103a304f77da68d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, containers@lists.linux-foundation.org, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Daniel Walsh <dwalsh@redhat.com>, William Dauchy <wdauchy@gmail.com>, Max Kellermann <mk@cm4all.com>, cgroups@vger.kernel.org, Daniel Berrange <berrange@redhat.com>

--001a1133d9665103a304f77da68d
Content-Type: text/plain; charset=UTF-8

I would still be in strong support of a cgroup replacement for NPROC rlimit.
On Apr 20, 2014 7:29 AM, "Richard Davies" <richard@arachsys.com> wrote:

> Vladimir Davydov wrote:
> > Richard Davies wrote:
> > > I have a simple reproducible test case in which untar in a memcg with a
> > > kmem limit gets into trouble during heavy disk i/o (on ext3) and never
> > > properly recovers. This is simplified from real world problems with
> > > heavy disk i/o inside containers.
> >
> > Unfortunately, work on per cgroup kmem limits is not completed yet.
> > Currently it lacks kmem reclaim on per cgroup memory pressure, which is
> > vital for using kmem limits in real life.
> ...
> > In short, kmem limiting for memory cgroups is currently broken. Do not
> > use it. We are working on making it usable though.
>
> Thanks for explaining the strange errors I got.
>
>
> My motivation is to prevent a fork bomb in a container from affecting other
> processes outside that container.
>
> kmem limits were the preferred mechanism in several previous discussions
> about two years ago (I'm copying in participants from those previous
> discussions and give links below). So I tried kmem first but found bugs.
>
>
> What is the best mechanism available today, until kmem limits mature?
>
> RLIMIT_NPROC exists but is per-user, not per-container.
>
> Perhaps there is an up-to-date task counter patchset or similar?
>
>
> Thank you all,
>
> Richard.
>
>
>
> Some references to previous discussions:
>
> Fork bomb limitation in memcg WAS: Re: [PATCH 00/11] kmem controller for
> memcg: stripped down version
> http://thread.gmane.org/gmane.linux.kernel/1318266/focus=1319372
>
> Re: [PATCH 00/10] cgroups: Task counter subsystem v8
> http://thread.gmane.org/gmane.linux.kernel/1246704/focus=1467310
>
> [RFD] Merge task counter into memcg
> http://thread.gmane.org/gmane.linux.kernel/1280302
>
> Re: [PATCH -mm] cgroup: Fix task counter common ancestor logic
> http://thread.gmane.org/gmane.linux.kernel/1212650/focus=1220186
>
> [PATCH] new cgroup controller "fork"
> http://thread.gmane.org/gmane.linux.kernel/1210878
>
> Re: Process Limit cgroups
> http://thread.gmane.org/gmane.linux.kernel.cgroups/9368/focus=9369
>
> Re: [lxc-devel] process number limit
> https://www.mail-archive.com/lxc-devel@lists.sourceforge.net/msg03309.html
>

--001a1133d9665103a304f77da68d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">I would still be in strong support of a cgroup replacement f=
or NPROC rlimit.</p>
<div class=3D"gmail_quote">On Apr 20, 2014 7:29 AM, &quot;Richard Davies&qu=
ot; &lt;<a href=3D"mailto:richard@arachsys.com">richard@arachsys.com</a>&gt=
; wrote:<br type=3D"attribution"><blockquote class=3D"gmail_quote" style=3D=
"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
Vladimir Davydov wrote:<br>
&gt; Richard Davies wrote:<br>
&gt; &gt; I have a simple reproducible test case in which untar in a memcg =
with a<br>
&gt; &gt; kmem limit gets into trouble during heavy disk i/o (on ext3) and =
never<br>
&gt; &gt; properly recovers. This is simplified from real world problems wi=
th<br>
&gt; &gt; heavy disk i/o inside containers.<br>
&gt;<br>
&gt; Unfortunately, work on per cgroup kmem limits is not completed yet.<br=
>
&gt; Currently it lacks kmem reclaim on per cgroup memory pressure, which i=
s<br>
&gt; vital for using kmem limits in real life.<br>
...<br>
&gt; In short, kmem limiting for memory cgroups is currently broken. Do not=
<br>
&gt; use it. We are working on making it usable though.<br>
<br>
Thanks for explaining the strange errors I got.<br>
<br>
<br>
My motivation is to prevent a fork bomb in a container from affecting other=
<br>
processes outside that container.<br>
<br>
kmem limits were the preferred mechanism in several previous discussions<br=
>
about two years ago (I&#39;m copying in participants from those previous<br=
>
discussions and give links below). So I tried kmem first but found bugs.<br=
>
<br>
<br>
What is the best mechanism available today, until kmem limits mature?<br>
<br>
RLIMIT_NPROC exists but is per-user, not per-container.<br>
<br>
Perhaps there is an up-to-date task counter patchset or similar?<br>
<br>
<br>
Thank you all,<br>
<br>
Richard.<br>
<br>
<br>
<br>
Some references to previous discussions:<br>
<br>
Fork bomb limitation in memcg WAS: Re: [PATCH 00/11] kmem controller for me=
mcg: stripped down version<br>
<a href=3D"http://thread.gmane.org/gmane.linux.kernel/1318266/focus=3D13193=
72" target=3D"_blank">http://thread.gmane.org/gmane.linux.kernel/1318266/fo=
cus=3D1319372</a><br>
<br>
Re: [PATCH 00/10] cgroups: Task counter subsystem v8<br>
<a href=3D"http://thread.gmane.org/gmane.linux.kernel/1246704/focus=3D14673=
10" target=3D"_blank">http://thread.gmane.org/gmane.linux.kernel/1246704/fo=
cus=3D1467310</a><br>
<br>
[RFD] Merge task counter into memcg<br>
<a href=3D"http://thread.gmane.org/gmane.linux.kernel/1280302" target=3D"_b=
lank">http://thread.gmane.org/gmane.linux.kernel/1280302</a><br>
<br>
Re: [PATCH -mm] cgroup: Fix task counter common ancestor logic<br>
<a href=3D"http://thread.gmane.org/gmane.linux.kernel/1212650/focus=3D12201=
86" target=3D"_blank">http://thread.gmane.org/gmane.linux.kernel/1212650/fo=
cus=3D1220186</a><br>
<br>
[PATCH] new cgroup controller &quot;fork&quot;<br>
<a href=3D"http://thread.gmane.org/gmane.linux.kernel/1210878" target=3D"_b=
lank">http://thread.gmane.org/gmane.linux.kernel/1210878</a><br>
<br>
Re: Process Limit cgroups<br>
<a href=3D"http://thread.gmane.org/gmane.linux.kernel.cgroups/9368/focus=3D=
9369" target=3D"_blank">http://thread.gmane.org/gmane.linux.kernel.cgroups/=
9368/focus=3D9369</a><br>
<br>
Re: [lxc-devel] process number limit<br>
<a href=3D"https://www.mail-archive.com/lxc-devel@lists.sourceforge.net/msg=
03309.html" target=3D"_blank">https://www.mail-archive.com/lxc-devel@lists.=
sourceforge.net/msg03309.html</a><br>
</blockquote></div>

--001a1133d9665103a304f77da68d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
