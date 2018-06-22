Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE4FC6B0006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 06:42:22 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 70-v6so3536817plc.1
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 03:42:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10-v6si7085458pla.140.2018.06.22.03.42.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 03:42:21 -0700 (PDT)
Date: Fri, 22 Jun 2018 12:42:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9] Refactor part of the oom report in dump_header
Message-ID: <20180622104217.GV10465@dhcp22.suse.cz>
References: <1529056341-16182-1-git-send-email-ufo19890607@gmail.com>
 <20180622083949.GR10465@dhcp22.suse.cz>
 <CAHCio2jkE2FGc2g48jm+ddvEbN3hEOoohBM+-871v32N2i2gew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2jkE2FGc2g48jm+ddvEbN3hEOoohBM+-871v32N2i2gew@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Fri 22-06-18 17:33:12, c|1e??e?(R) wrote:
> Hi Michal
> > diff --git a/include/linux/oom.h b/include/linux/oom.h
> > index 6adac113e96d..5bed78d4bfb8 100644
> > --- a/include/linux/oom.h
> > +++ b/include/linux/oom.h
> > @@ -15,6 +15,20 @@ struct notifier_block;
> >  struct mem_cgroup;
> >  struct task_struct;
> >
> > +enum oom_constraint {
> > +     CONSTRAINT_NONE,
> > +     CONSTRAINT_CPUSET,
> > +     CONSTRAINT_MEMORY_POLICY,
> > +     CONSTRAINT_MEMCG,
> > +};
> > +
> > +static const char * const oom_constraint_text[] = {
> > +     [CONSTRAINT_NONE] = "CONSTRAINT_NONE",
> > +     [CONSTRAINT_CPUSET] = "CONSTRAINT_CPUSET",
> > +     [CONSTRAINT_MEMORY_POLICY] = "CONSTRAINT_MEMORY_POLICY",
> > +     [CONSTRAINT_MEMCG] = "CONSTRAINT_MEMCG",
> > +};
> 
> > I've suggested that this should be a separate patch.
> I've separate this part in patch v7.
> 
> [PATCH v7 1/2] Add an array of const char and enum oom_constraint in
> memcontrol.h
> On Sat 02-06-18 19:58:51, ufo19890607@gmail.com wrote:
> >> From: yuzhoujian <yuzhoujian@didichuxing.com>
> >>
> >> This patch will make some preparation for the follow-up patch: Refactor
> >> part of the oom report in dump_header. It puts enum oom_constraint in
> >> memcontrol.h and adds an array of const char for each constraint.
> 
> > I do not get why you separate this specific part out.
> > oom_constraint_text is not used in the patch. It is almost always
> > preferable to have a user of newly added functionality.
> 
> So do I need to separate this part ?

You misunderstood my suggestion. Let me be more specific. Please
separate the whole new oom_constraint including its _usage_.
-- 
Michal Hocko
SUSE Labs
