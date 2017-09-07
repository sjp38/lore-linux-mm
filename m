Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 859E96B031D
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 15:43:37 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id i196so1253690ywg.5
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 12:43:37 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o188sor64245ywe.157.2017.09.07.12.43.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Sep 2017 12:43:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170907184745.GA20598@castle.DHCP.thefacebook.com>
References: <20170829100150.4580-1-guro@fb.com> <20170829192621.GA5447@cmpxchg.org>
 <20170830105524.GA2852@castle.dhcp.TheFacebook.com> <CALvZod5zP=LL=LhD0WX-zX4mPbn7F_obQmpCrrin9YuBQHJLow@mail.gmail.com>
 <20170907184745.GA20598@castle.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 7 Sep 2017 12:43:35 -0700
Message-ID: <CALvZod6jNNA=j0WzUzjLxe0vnZeCsJEZ=Q92CgfT65-g2tdCfg@mail.gmail.com>
Subject: Re: [PATCH] mm: memcontrol: use per-cpu stocks for socket memory uncharging
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, kernel-team@fb.com, LKML <linux-kernel@vger.kernel.org>

On Thu, Sep 7, 2017 at 11:47 AM, Roman Gushchin <guro@fb.com> wrote:
> On Thu, Sep 07, 2017 at 11:44:12AM -0700, Shakeel Butt wrote:
>> >> As far as other types of pages go: page cache and anon are already
>> >> batched pretty well, but I think kmem might benefit from this
>> >> too. Have you considered using the stock in memcg_kmem_uncharge()?
>> >
>> > Good idea!
>> > I'll try to find an appropriate testcase and check if it really
>> > brings any benefits. If so, I'll master a patch.
>> >
>>
>> Hi Roman, did you get the chance to try this on memcg_kmem_uncharge()?
>
> Hi Shakeel!
>
> Not yet, I'll try to it asap.
> Do you have an example when it's costly?
>

Nah, I was also curious of such examples.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
