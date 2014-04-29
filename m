Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id C0FE66B0039
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 10:04:11 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id id10so318824vcb.17
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 07:04:11 -0700 (PDT)
Received: from mail-ve0-x230.google.com (mail-ve0-x230.google.com [2607:f8b0:400c:c01::230])
        by mx.google.com with ESMTPS id jb7si4530048vec.35.2014.04.29.07.04.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 07:04:11 -0700 (PDT)
Received: by mail-ve0-f176.google.com with SMTP id db11so307283veb.7
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 07:04:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140429130353.GA27354@ubuntumail>
References: <20140416154650.GA3034@alpha.arachsys.com>
	<20140418155939.GE4523@dhcp22.suse.cz>
	<5351679F.5040908@parallels.com>
	<20140420142830.GC22077@alpha.arachsys.com>
	<20140422143943.20609800@oracle.com>
	<20140422200531.GA19334@alpha.arachsys.com>
	<535758A0.5000500@yuhu.biz>
	<20140423084942.560ae837@oracle.com>
	<20140428180025.GC25689@ubuntumail>
	<20140429072515.GB15058@dhcp22.suse.cz>
	<20140429130353.GA27354@ubuntumail>
Date: Tue, 29 Apr 2014 07:04:10 -0700
Message-ID: <CAO_RewbeGz5EkExxqJ5h08Fu5GUVszhTLVjHwsnj_F3sVSFJYg@mail.gmail.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with kmem
 limit doesn't recover after disk i/o causes limit to be hit]
From: Tim Hockin <thockin@google.com>
Content-Type: multipart/alternative; boundary=bcaec548a9b7f7a96f04f82ee7ca
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Marian Marinov <mm@yuhu.biz>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, containers@lists.linux-foundation.org, Tim Hockin <thockin@hockin.org>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Daniel Walsh <dwalsh@redhat.com>, William Dauchy <wdauchy@gmail.com>, Max Kellermann <mk@cm4all.com>, cgroups@vger.kernel.org, Richard Davies <richard@arachsys.com>

--bcaec548a9b7f7a96f04f82ee7ca
Content-Type: text/plain; charset=ISO-8859-1

Thank you.  These are two different things.  They may have a relationship
but they ate not the same, and pretending they are is a bad experience.
On Apr 29, 2014 6:04 AM, "Serge Hallyn" <serge.hallyn@ubuntu.com> wrote:

> Quoting Michal Hocko (mhocko@suse.cz):
> > On Mon 28-04-14 18:00:25, Serge Hallyn wrote:
> > > Quoting Dwight Engen (dwight.engen@oracle.com):
> > > > On Wed, 23 Apr 2014 09:07:28 +0300
> > > > Marian Marinov <mm@yuhu.biz> wrote:
> > > >
> > > > > On 04/22/2014 11:05 PM, Richard Davies wrote:
> > > > > > Dwight Engen wrote:
> > > > > >> Richard Davies wrote:
> > > > > >>> Vladimir Davydov wrote:
> > > > > >>>> In short, kmem limiting for memory cgroups is currently
> broken.
> > > > > >>>> Do not use it. We are working on making it usable though.
> > > > > > ...
> > > > > >>> What is the best mechanism available today, until kmem limits
> > > > > >>> mature?
> > > > > >>>
> > > > > >>> RLIMIT_NPROC exists but is per-user, not per-container.
> > > > > >>>
> > > > > >>> Perhaps there is an up-to-date task counter patchset or
> similar?
> > > > > >>
> > > > > >> I updated Frederic's task counter patches and included Max
> > > > > >> Kellermann's fork limiter here:
> > > > > >>
> > > > > >> http://thread.gmane.org/gmane.linux.kernel.containers/27212
> > > > > >>
> > > > > >> I can send you a more recent patchset (against 3.13.10) if you
> > > > > >> would find it useful.
> > > > > >
> > > > > > Yes please, I would be interested in that. Ideally even against
> > > > > > 3.14.1 if you have that too.
> > > > >
> > > > > Dwight, do you have these patches in any public repo?
> > > > >
> > > > > I would like to test them also.
> > > >
> > > > Hi Marian, I put the patches against 3.13.11 and 3.14.1 up at:
> > > >
> > > > git://github.com/dwengen/linux.git cpuacct-task-limit-3.13
> > > > git://github.com/dwengen/linux.git cpuacct-task-limit-3.14
> > >
> > > Thanks, Dwight.  FWIW I'm agreed with Tim, Dwight, Richard, and Marian
> > > that a task limit would be a proper cgroup extension, and specifically
> > > that approximating that with a kmem limit is not a reasonable
> substitute.
> >
> > The current state of the kmem limit, which is improving a lot thanks to
> > Vladimir, is not a reason for a new extension/controller. We are just
> > not yet there.
>
> It has nothing to do with the state of the limit.  I simply don't
> believe that emulating RLIMIT_NPROC by controlling stack size is a
> good idea.
>
> -serge
>

--bcaec548a9b7f7a96f04f82ee7ca
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">Thank you.=A0 These are two different things.=A0 They may ha=
ve a relationship but they ate not the same, and pretending they are is a b=
ad experience.</p>
<div class=3D"gmail_quote">On Apr 29, 2014 6:04 AM, &quot;Serge Hallyn&quot=
; &lt;<a href=3D"mailto:serge.hallyn@ubuntu.com">serge.hallyn@ubuntu.com</a=
>&gt; wrote:<br type=3D"attribution"><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
Quoting Michal Hocko (<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.cz</a>)=
:<br>
&gt; On Mon 28-04-14 18:00:25, Serge Hallyn wrote:<br>
&gt; &gt; Quoting Dwight Engen (<a href=3D"mailto:dwight.engen@oracle.com">=
dwight.engen@oracle.com</a>):<br>
&gt; &gt; &gt; On Wed, 23 Apr 2014 09:07:28 +0300<br>
&gt; &gt; &gt; Marian Marinov &lt;<a href=3D"mailto:mm@yuhu.biz">mm@yuhu.bi=
z</a>&gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; On 04/22/2014 11:05 PM, Richard Davies wrote:<br>
&gt; &gt; &gt; &gt; &gt; Dwight Engen wrote:<br>
&gt; &gt; &gt; &gt; &gt;&gt; Richard Davies wrote:<br>
&gt; &gt; &gt; &gt; &gt;&gt;&gt; Vladimir Davydov wrote:<br>
&gt; &gt; &gt; &gt; &gt;&gt;&gt;&gt; In short, kmem limiting for memory cgr=
oups is currently broken.<br>
&gt; &gt; &gt; &gt; &gt;&gt;&gt;&gt; Do not use it. We are working on makin=
g it usable though.<br>
&gt; &gt; &gt; &gt; &gt; ...<br>
&gt; &gt; &gt; &gt; &gt;&gt;&gt; What is the best mechanism available today=
, until kmem limits<br>
&gt; &gt; &gt; &gt; &gt;&gt;&gt; mature?<br>
&gt; &gt; &gt; &gt; &gt;&gt;&gt;<br>
&gt; &gt; &gt; &gt; &gt;&gt;&gt; RLIMIT_NPROC exists but is per-user, not p=
er-container.<br>
&gt; &gt; &gt; &gt; &gt;&gt;&gt;<br>
&gt; &gt; &gt; &gt; &gt;&gt;&gt; Perhaps there is an up-to-date task counte=
r patchset or similar?<br>
&gt; &gt; &gt; &gt; &gt;&gt;<br>
&gt; &gt; &gt; &gt; &gt;&gt; I updated Frederic&#39;s task counter patches =
and included Max<br>
&gt; &gt; &gt; &gt; &gt;&gt; Kellermann&#39;s fork limiter here:<br>
&gt; &gt; &gt; &gt; &gt;&gt;<br>
&gt; &gt; &gt; &gt; &gt;&gt; <a href=3D"http://thread.gmane.org/gmane.linux=
.kernel.containers/27212" target=3D"_blank">http://thread.gmane.org/gmane.l=
inux.kernel.containers/27212</a><br>
&gt; &gt; &gt; &gt; &gt;&gt;<br>
&gt; &gt; &gt; &gt; &gt;&gt; I can send you a more recent patchset (against=
 3.13.10) if you<br>
&gt; &gt; &gt; &gt; &gt;&gt; would find it useful.<br>
&gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; Yes please, I would be interested in that. Ideally=
 even against<br>
&gt; &gt; &gt; &gt; &gt; 3.14.1 if you have that too.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Dwight, do you have these patches in any public repo?<b=
r>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; I would like to test them also.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Hi Marian, I put the patches against 3.13.11 and 3.14.1 up a=
t:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; git://<a href=3D"http://github.com/dwengen/linux.git" target=
=3D"_blank">github.com/dwengen/linux.git</a> cpuacct-task-limit-3.13<br>
&gt; &gt; &gt; git://<a href=3D"http://github.com/dwengen/linux.git" target=
=3D"_blank">github.com/dwengen/linux.git</a> cpuacct-task-limit-3.14<br>
&gt; &gt;<br>
&gt; &gt; Thanks, Dwight. =A0FWIW I&#39;m agreed with Tim, Dwight, Richard,=
 and Marian<br>
&gt; &gt; that a task limit would be a proper cgroup extension, and specifi=
cally<br>
&gt; &gt; that approximating that with a kmem limit is not a reasonable sub=
stitute.<br>
&gt;<br>
&gt; The current state of the kmem limit, which is improving a lot thanks t=
o<br>
&gt; Vladimir, is not a reason for a new extension/controller. We are just<=
br>
&gt; not yet there.<br>
<br>
It has nothing to do with the state of the limit. =A0I simply don&#39;t<br>
believe that emulating RLIMIT_NPROC by controlling stack size is a<br>
good idea.<br>
<br>
-serge<br>
</blockquote></div>

--bcaec548a9b7f7a96f04f82ee7ca--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
