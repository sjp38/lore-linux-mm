Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31B4B6B0253
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 16:09:35 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r18so2507613qkh.4
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 13:09:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r63sor482318ybf.51.2017.10.02.13.09.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 13:09:34 -0700 (PDT)
MIME-Version: 1.0
References: <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
 <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz> <CAAAKZws2CFExeg6A9AzrGjiHnFHU1h2xdk6J5Jw2kqxy=V+_YQ@mail.gmail.com>
 <20170927162300.GA5623@castle.DHCP.thefacebook.com> <CAAAKZwtApj-FgRc2V77nEb3BUd97Rwhgf-b-k0zhf1u+Y4fqxA@mail.gmail.com>
 <CALvZod7iaOEeGmDJA0cZvJWpuzc-hMRn3PG2cfzcMniJtAjKqA@mail.gmail.com>
 <20171002122434.llbaarb6yw3o3mx3@dhcp22.suse.cz> <CALvZod65LYZZYy6uE=DQaQRPXYAhAci=NMG_w=ZANPGATgRwfg@mail.gmail.com>
 <20171002192814.sad75tqklp3nmr4m@dhcp22.suse.cz> <CALvZod4=+GVg+hrT4ubp9P4b+LUZ+q9mz4ztC=Fc_cmTZmvpcw@mail.gmail.com>
 <20171002195601.3jeocmmzyf2jl3dw@dhcp22.suse.cz> <CAAAKZwtfXBEe=K93J0U35aMeFaBS8eJ9yN3kRE9=+yKzNnV_Nw@mail.gmail.com>
In-Reply-To: <CAAAKZwtfXBEe=K93J0U35aMeFaBS8eJ9yN3kRE9=+yKzNnV_Nw@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 02 Oct 2017 20:09:23 +0000
Message-ID: <CALvZod7AfHC_zk7fhrBsrefA9+XUsGJFykECt9E_8wJ14LAaAw@mail.gmail.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Content-Type: multipart/alternative; boundary="001a1148b520015ff0055a95f48b"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tim Hockin <thockin@hockin.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--001a1148b520015ff0055a95f48b
Content-Type: text/plain; charset="UTF-8"

On Mon, Oct 2, 2017 at 1:01 PM Tim Hockin <thockin@hockin.org> wrote:

> In the example above:
>
>        root
>        /    \
>      A      D
>      / \
>    B   C
>
> Does oom_group allow me to express "compare A and D; if A is chosen
> compare B and C; kill the loser" ?  As I understand the proposal (from
> reading thread, not patch) it does not.


It will let you compare A and D and if A is chosen then kill A, B and C.


>
> On Mon, Oct 2, 2017 at 12:56 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Mon 02-10-17 12:45:18, Shakeel Butt wrote:
> >> > I am sorry to cut the rest of your proposal because it simply goes
> over
> >> > the scope of the proposed solution while the usecase you are
> mentioning
> >> > is still possible. If we want to compare intermediate nodes (which
> seems
> >> > to be the case) then we can always provide a knob to opt-in - be it
> your
> >> > oom_gang or others.
> >>
> >> In the Roman's proposed solution we can already force the comparison
> >> of intermediate nodes using 'oom_group', I am just requesting to
> >> separate the killall semantics from it.
> >
> > oom_group _is_ about killall semantic.  And comparing killable entities
> > is just a natural thing to do. So I am not sure what you mean
> >
> > --
> > Michal Hocko
> > SUSE Labs
>

--001a1148b520015ff0055a95f48b
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div><br><div class=3D"gmail_quote"><div dir=3D"auto">On Mon, Oct 2, 2017 a=
t 1:01 PM Tim Hockin &lt;<a href=3D"mailto:thockin@hockin.org">thockin@hock=
in.org</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">In the exampl=
e above:<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0root<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0/=C2=A0 =C2=A0 \<br>
=C2=A0 =C2=A0 =C2=A0A=C2=A0 =C2=A0 =C2=A0 D<br>
=C2=A0 =C2=A0 =C2=A0/ \<br>
=C2=A0 =C2=A0B=C2=A0 =C2=A0C<br>
<br>
Does oom_group allow me to express &quot;compare A and D; if A is chosen<br=
>
compare B and C; kill the loser&quot; ?=C2=A0 As I understand the proposal =
(from<br>
reading thread, not patch) it does not.</blockquote><div dir=3D"auto"><br><=
/div><div dir=3D"auto">It will let you compare A and D and if A is chosen t=
hen kill A, B and C.</div><div dir=3D"auto"><br></div><blockquote class=3D"=
gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-=
left:1ex"><br>
<br>
On Mon, Oct 2, 2017 at 12:56 PM, Michal Hocko &lt;<a href=3D"mailto:mhocko@=
kernel.org" target=3D"_blank">mhocko@kernel.org</a>&gt; wrote:<br>
&gt; On Mon 02-10-17 12:45:18, Shakeel Butt wrote:<br>
&gt;&gt; &gt; I am sorry to cut the rest of your proposal because it simply=
 goes over<br>
&gt;&gt; &gt; the scope of the proposed solution while the usecase you are =
mentioning<br>
&gt;&gt; &gt; is still possible. If we want to compare intermediate nodes (=
which seems<br>
&gt;&gt; &gt; to be the case) then we can always provide a knob to opt-in -=
 be it your<br>
&gt;&gt; &gt; oom_gang or others.<br>
&gt;&gt;<br>
&gt;&gt; In the Roman&#39;s proposed solution we can already force the comp=
arison<br>
&gt;&gt; of intermediate nodes using &#39;oom_group&#39;, I am just request=
ing to<br>
&gt;&gt; separate the killall semantics from it.<br>
&gt;<br>
&gt; oom_group _is_ about killall semantic.=C2=A0 And comparing killable en=
tities<br>
&gt; is just a natural thing to do. So I am not sure what you mean<br>
&gt;<br>
&gt; --<br>
&gt; Michal Hocko<br>
&gt; SUSE Labs<br>
</blockquote></div></div>

--001a1148b520015ff0055a95f48b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
