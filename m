Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C121C6B03C1
	for <linux-mm@kvack.org>; Thu, 17 May 2018 05:44:58 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a5-v6so1756892lfi.8
        for <linux-mm@kvack.org>; Thu, 17 May 2018 02:44:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c13-v6sor1118332ljk.25.2018.05.17.02.44.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 May 2018 02:44:56 -0700 (PDT)
MIME-Version: 1.0
References: <1526540428-12178-1-git-send-email-ufo19890607@gmail.com> <20180517071140.GQ12670@dhcp22.suse.cz>
In-Reply-To: <20180517071140.GQ12670@dhcp22.suse.cz>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Thu, 17 May 2018 17:44:43 +0800
Message-ID: <CAHCio2gOLnj4NpkFrxpYVygg6ZeSeuwgp2Lwr6oTHRxHpbmcWw@mail.gmail.com>
Subject: Re: [PATCH] Add the memcg print oom info for system oom
Content-Type: multipart/alternative; boundary="000000000000262797056c63b00f"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

--000000000000262797056c63b00f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Michal
I think the current OOM report is imcomplete. I can get the task which
invoked the oom-killer and the task which has been killed by the
oom-killer, and memory info when the oom happened. But I cannot infer the
certain memcg to which the task killed by oom-killer belongs, because that
task has been killed, and the dump_task will print all of the tasks in the
system.

mem_cgroup_print_oom_info will print five lines of content including
memcg's name , usage, limit. I don't think five lines of content will cause
a big problem. Or it at least prints the memcg's name.

Thanks
Wind

Michal Hocko <mhocko@kernel.org> =E4=BA=8E2018=E5=B9=B45=E6=9C=8817=E6=97=
=A5=E5=91=A8=E5=9B=9B =E4=B8=8B=E5=8D=883:11=E5=86=99=E9=81=93=EF=BC=9A

> On Thu 17-05-18 08:00:28, ufo19890607 wrote:
> > From: yuzhoujian <yuzhoujian@didichuxing.com>
> >
> > The dump_header does not print the memcg's name when the system
> > oom happened. Some users want to locate the certain container
> > which contains the task that has been killed by the oom killer.
> > So I add the mem_cgroup_print_oom_info when system oom events
> > happened.
>
> The oom report is quite heavy today. Do we really need the full memcg
> oom report here. Wouldn't it be sufficient to print the memcg the task
> belongs to?
>
> > Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
> > ---
> >  mm/oom_kill.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 8ba6cb88cf58..244416c9834a 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -433,6 +433,7 @@ static void dump_header(struct oom_control *oc,
> struct task_struct *p)
> >       if (is_memcg_oom(oc))
> >               mem_cgroup_print_oom_info(oc->memcg, p);
> >       else {
> > +             mem_cgroup_print_oom_info(mem_cgroup_from_task(p), p);
> >               show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
> >               if (is_dump_unreclaim_slabs())
> >                       dump_unreclaimable_slab();
> > --
> > 2.14.1
> >
>
> --
> Michal Hocko
> SUSE Labs
>

--000000000000262797056c63b00f
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hi Michal</div><div>I think the current OOM report is=
 imcomplete. I can get the task which invoked the oom-killer and the task w=
hich has been killed by the oom-killer, and memory info when the oom happen=
ed. But I cannot infer the certain memcg to which the task killed by oom-ki=
ller belongs, because that task has been killed, and the dump_task will pri=
nt all of the tasks in the system. <br></div><div><br></div><div>mem_cgroup=
_print_oom_info will print five lines of content including memcg&#39;s name=
 , usage, limit. I don&#39;t think five lines of content will cause a big p=
roblem. Or it at least prints the memcg&#39;s name. <br></div><div><br></di=
v><div>Thanks</div><div>Wind<br></div></div><br><div class=3D"gmail_quote">=
<div dir=3D"ltr">Michal Hocko &lt;<a href=3D"mailto:mhocko@kernel.org">mhoc=
ko@kernel.org</a>&gt; =E4=BA=8E2018=E5=B9=B45=E6=9C=8817=E6=97=A5=E5=91=A8=
=E5=9B=9B =E4=B8=8B=E5=8D=883:11=E5=86=99=E9=81=93=EF=BC=9A<br></div><block=
quote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc=
 solid;padding-left:1ex">On Thu 17-05-18 08:00:28, ufo19890607 wrote:<br>
&gt; From: yuzhoujian &lt;<a href=3D"mailto:yuzhoujian@didichuxing.com" tar=
get=3D"_blank">yuzhoujian@didichuxing.com</a>&gt;<br>
&gt; <br>
&gt; The dump_header does not print the memcg&#39;s name when the system<br=
>
&gt; oom happened. Some users want to locate the certain container<br>
&gt; which contains the task that has been killed by the oom killer.<br>
&gt; So I add the mem_cgroup_print_oom_info when system oom events<br>
&gt; happened.<br>
<br>
The oom report is quite heavy today. Do we really need the full memcg<br>
oom report here. Wouldn&#39;t it be sufficient to print the memcg the task<=
br>
belongs to?<br>
<br>
&gt; Signed-off-by: yuzhoujian &lt;<a href=3D"mailto:yuzhoujian@didichuxing=
.com" target=3D"_blank">yuzhoujian@didichuxing.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 mm/oom_kill.c | 1 +<br>
&gt;=C2=A0 1 file changed, 1 insertion(+)<br>
&gt; <br>
&gt; diff --git a/mm/oom_kill.c b/mm/oom_kill.c<br>
&gt; index 8ba6cb88cf58..244416c9834a 100644<br>
&gt; --- a/mm/oom_kill.c<br>
&gt; +++ b/mm/oom_kill.c<br>
&gt; @@ -433,6 +433,7 @@ static void dump_header(struct oom_control *oc, st=
ruct task_struct *p)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0if (is_memcg_oom(oc))<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_print=
_oom_info(oc-&gt;memcg, p);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0else {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_print_oom_=
info(mem_cgroup_from_task(p), p);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0show_mem(SHOW_ME=
M_FILTER_NODES, oc-&gt;nodemask);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (is_dump_unre=
claim_slabs())<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0dump_unreclaimable_slab();<br>
&gt; -- <br>
&gt; 2.14.1<br>
&gt; <br>
<br>
-- <br>
Michal Hocko<br>
SUSE Labs<br>
</blockquote></div>

--000000000000262797056c63b00f--
