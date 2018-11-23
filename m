Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5602D6B2F8D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 01:11:23 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id e8-v6so3112416ljg.22
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 22:11:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a22-v6sor9938989ljd.6.2018.11.22.22.11.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 22:11:21 -0800 (PST)
MIME-Version: 1.0
References: <1542799799-36184-1-git-send-email-ufo19890607@gmail.com>
 <1542799799-36184-2-git-send-email-ufo19890607@gmail.com> <20181122133954.GI18011@dhcp22.suse.cz>
In-Reply-To: <20181122133954.GI18011@dhcp22.suse.cz>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Fri, 23 Nov 2018 14:11:09 +0800
Message-ID: <CAHCio2gdCX3p-7=N0cA22cWTaUmUXRq8WbiMAA2sM2wLVX4GjQ@mail.gmail.com>
Subject: Re: [PATCH v15 2/2] Add oom victim's memcg to the oom context information
Content-Type: multipart/alternative; boundary="00000000000024b275057b4eda1a"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

--00000000000024b275057b4eda1a
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Michal
I just rebase the patch from the latest version.


Michal Hocko <mhocko@kernel.org> =E4=BA=8E2018=E5=B9=B411=E6=9C=8822=E6=97=
=A5=E5=91=A8=E5=9B=9B =E4=B8=8B=E5=8D=889:39=E5=86=99=E9=81=93=EF=BC=9A

> On Wed 21-11-18 19:29:59, ufo19890607@gmail.com wrote:
> > From: yuzhoujian <yuzhoujian@didichuxing.com>
> >
> > The current oom report doesn't display victim's memcg context during th=
e
> > global OOM situation. While this information is not strictly needed, it
> > can be really helpful for containerized environments to locate which
> > container has lost a process. Now that we have a single line for the oo=
m
> > context, we can trivially add both the oom memcg (this can be either
> > global_oom or a specific memcg which hits its hard limits) and task_mem=
cg
> > which is the victim's memcg.
> >
> > Below is the single line output in the oom report after this patch.
> > - global oom context information:
> >
> oom-kill:constraint=3D<constraint>,nodemask=3D<nodemask>,cpuset=3D<cpuset=
>,mems_allowed=3D<mems_allowed>,global_oom,task_memcg=3D<memcg>,task=3D<com=
m>,pid=3D<pid>,uid=3D<uid>
> > - memcg oom context information:
> >
> oom-kill:constraint=3D<constraint>,nodemask=3D<nodemask>,cpuset=3D<cpuset=
>,mems_allowed=3D<mems_allowed>,oom_memcg=3D<memcg>,task_memcg=3D<memcg>,ta=
sk=3D<comm>,pid=3D<pid>,uid=3D<uid>
> >
> > Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
>
> I thought I have acked this one already.
> Acked-by: Michal Hocko <mhocko@suse.com>
> --
> Michal Hocko
> SUSE Labs
>

--00000000000024b275057b4eda1a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Michal<div>I just rebase the patch from the latest vers=
ion.</div></div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">Michal =
Hocko &lt;<a href=3D"mailto:mhocko@kernel.org">mhocko@kernel.org</a>&gt; =
=E4=BA=8E2018=E5=B9=B411=E6=9C=8822=E6=97=A5=E5=91=A8=E5=9B=9B =E4=B8=8B=E5=
=8D=889:39=E5=86=99=E9=81=93=EF=BC=9A<br></div><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x">On Wed 21-11-18 19:29:59, <a href=3D"mailto:ufo19890607@gmail.com" targe=
t=3D"_blank">ufo19890607@gmail.com</a> wrote:<br>
&gt; From: yuzhoujian &lt;<a href=3D"mailto:yuzhoujian@didichuxing.com" tar=
get=3D"_blank">yuzhoujian@didichuxing.com</a>&gt;<br>
&gt; <br>
&gt; The current oom report doesn&#39;t display victim&#39;s memcg context =
during the<br>
&gt; global OOM situation. While this information is not strictly needed, i=
t<br>
&gt; can be really helpful for containerized environments to locate which<b=
r>
&gt; container has lost a process. Now that we have a single line for the o=
om<br>
&gt; context, we can trivially add both the oom memcg (this can be either<b=
r>
&gt; global_oom or a specific memcg which hits its hard limits) and task_me=
mcg<br>
&gt; which is the victim&#39;s memcg.<br>
&gt; <br>
&gt; Below is the single line output in the oom report after this patch.<br=
>
&gt; - global oom context information:<br>
&gt; oom-kill:constraint=3D&lt;constraint&gt;,nodemask=3D&lt;nodemask&gt;,c=
puset=3D&lt;cpuset&gt;,mems_allowed=3D&lt;mems_allowed&gt;,global_oom,task_=
memcg=3D&lt;memcg&gt;,task=3D&lt;comm&gt;,pid=3D&lt;pid&gt;,uid=3D&lt;uid&g=
t;<br>
&gt; - memcg oom context information:<br>
&gt; oom-kill:constraint=3D&lt;constraint&gt;,nodemask=3D&lt;nodemask&gt;,c=
puset=3D&lt;cpuset&gt;,mems_allowed=3D&lt;mems_allowed&gt;,oom_memcg=3D&lt;=
memcg&gt;,task_memcg=3D&lt;memcg&gt;,task=3D&lt;comm&gt;,pid=3D&lt;pid&gt;,=
uid=3D&lt;uid&gt;<br>
&gt; <br>
&gt; Signed-off-by: yuzhoujian &lt;<a href=3D"mailto:yuzhoujian@didichuxing=
.com" target=3D"_blank">yuzhoujian@didichuxing.com</a>&gt;<br>
<br>
I thought I have acked this one already.<br>
Acked-by: Michal Hocko &lt;<a href=3D"mailto:mhocko@suse.com" target=3D"_bl=
ank">mhocko@suse.com</a>&gt;<br>
-- <br>
Michal Hocko<br>
SUSE Labs<br>
</blockquote></div>

--00000000000024b275057b4eda1a--
