Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B7B4B6B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 07:41:09 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u14-v6so1839240lfu.22
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 04:41:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 67-v6sor1667455ljq.14.2018.06.22.04.41.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 04:41:07 -0700 (PDT)
MIME-Version: 1.0
References: <1529056341-16182-1-git-send-email-ufo19890607@gmail.com>
 <20180622083949.GR10465@dhcp22.suse.cz> <CAHCio2jkE2FGc2g48jm+ddvEbN3hEOoohBM+-871v32N2i2gew@mail.gmail.com>
 <20180622104217.GV10465@dhcp22.suse.cz>
In-Reply-To: <20180622104217.GV10465@dhcp22.suse.cz>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Fri, 22 Jun 2018 19:40:54 +0800
Message-ID: <CAHCio2j-z5y8sQrZ9ENLH2sOzuoH=vsC+q9Nj5DbSXUnQK-uPw@mail.gmail.com>
Subject: Re: [PATCH v9] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Michal
> You misunderstood my suggestion. Let me be more specific. Please
> separate the whole new oom_constraint including its _usage_.

Sorry for misunderstanding your words. I think you want me to separate
enum oom_constraint and static const char * const
oom_constraint_text[] to two parts, am I right ?
Michal Hocko <mhocko@kernel.org> =E4=BA=8E2018=E5=B9=B46=E6=9C=8822=E6=97=
=A5=E5=91=A8=E4=BA=94 =E4=B8=8B=E5=8D=886:42=E5=86=99=E9=81=93=EF=BC=9A
>
> On Fri 22-06-18 17:33:12, =E7=A6=B9=E8=88=9F=E9=94=AE wrote:
> > Hi Michal
> > > diff --git a/include/linux/oom.h b/include/linux/oom.h
> > > index 6adac113e96d..5bed78d4bfb8 100644
> > > --- a/include/linux/oom.h
> > > +++ b/include/linux/oom.h
> > > @@ -15,6 +15,20 @@ struct notifier_block;
> > >  struct mem_cgroup;
> > >  struct task_struct;
> > >
> > > +enum oom_constraint {
> > > +     CONSTRAINT_NONE,
> > > +     CONSTRAINT_CPUSET,
> > > +     CONSTRAINT_MEMORY_POLICY,
> > > +     CONSTRAINT_MEMCG,
> > > +};
> > > +
> > > +static const char * const oom_constraint_text[] =3D {
> > > +     [CONSTRAINT_NONE] =3D "CONSTRAINT_NONE",
> > > +     [CONSTRAINT_CPUSET] =3D "CONSTRAINT_CPUSET",
> > > +     [CONSTRAINT_MEMORY_POLICY] =3D "CONSTRAINT_MEMORY_POLICY",
> > > +     [CONSTRAINT_MEMCG] =3D "CONSTRAINT_MEMCG",
> > > +};
> >
> > > I've suggested that this should be a separate patch.
> > I've separate this part in patch v7.
> >
> > [PATCH v7 1/2] Add an array of const char and enum oom_constraint in
> > memcontrol.h
> > On Sat 02-06-18 19:58:51, ufo19890607@gmail.com wrote:
> > >> From: yuzhoujian <yuzhoujian@didichuxing.com>
> > >>
> > >> This patch will make some preparation for the follow-up patch: Refac=
tor
> > >> part of the oom report in dump_header. It puts enum oom_constraint i=
n
> > >> memcontrol.h and adds an array of const char for each constraint.
> >
> > > I do not get why you separate this specific part out.
> > > oom_constraint_text is not used in the patch. It is almost always
> > > preferable to have a user of newly added functionality.
> >
> > So do I need to separate this part ?
>
> You misunderstood my suggestion. Let me be more specific. Please
> separate the whole new oom_constraint including its _usage_.
> --
> Michal Hocko
> SUSE Labs
