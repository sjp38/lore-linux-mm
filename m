Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5CF756B000A
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 05:33:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h7-v6so1798041lfc.13
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 02:33:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n4-v6sor1581725ljh.98.2018.06.22.02.33.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 02:33:25 -0700 (PDT)
MIME-Version: 1.0
References: <1529056341-16182-1-git-send-email-ufo19890607@gmail.com> <20180622083949.GR10465@dhcp22.suse.cz>
In-Reply-To: <20180622083949.GR10465@dhcp22.suse.cz>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Fri, 22 Jun 2018 17:33:12 +0800
Message-ID: <CAHCio2jkE2FGc2g48jm+ddvEbN3hEOoohBM+-871v32N2i2gew@mail.gmail.com>
Subject: Re: [PATCH v9] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Michal
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 6adac113e96d..5bed78d4bfb8 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -15,6 +15,20 @@ struct notifier_block;
>  struct mem_cgroup;
>  struct task_struct;
>
> +enum oom_constraint {
> +     CONSTRAINT_NONE,
> +     CONSTRAINT_CPUSET,
> +     CONSTRAINT_MEMORY_POLICY,
> +     CONSTRAINT_MEMCG,
> +};
> +
> +static const char * const oom_constraint_text[] = {
> +     [CONSTRAINT_NONE] = "CONSTRAINT_NONE",
> +     [CONSTRAINT_CPUSET] = "CONSTRAINT_CPUSET",
> +     [CONSTRAINT_MEMORY_POLICY] = "CONSTRAINT_MEMORY_POLICY",
> +     [CONSTRAINT_MEMCG] = "CONSTRAINT_MEMCG",
> +};

> I've suggested that this should be a separate patch.
I've separate this part in patch v7.

[PATCH v7 1/2] Add an array of const char and enum oom_constraint in
memcontrol.h
On Sat 02-06-18 19:58:51, ufo19890607@gmail.com wrote:
>> From: yuzhoujian <yuzhoujian@didichuxing.com>
>>
>> This patch will make some preparation for the follow-up patch: Refactor
>> part of the oom report in dump_header. It puts enum oom_constraint in
>> memcontrol.h and adds an array of const char for each constraint.

> I do not get why you separate this specific part out.
> oom_constraint_text is not used in the patch. It is almost always
> preferable to have a user of newly added functionality.

So do I need to separate this part ?

Thanks
