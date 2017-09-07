Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99BA06B030E
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 14:48:08 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 11so858887pge.4
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 11:48:08 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u67si190220pgc.632.2017.09.07.11.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Sep 2017 11:48:07 -0700 (PDT)
Date: Thu, 7 Sep 2017 19:47:45 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: memcontrol: use per-cpu stocks for socket memory
 uncharging
Message-ID: <20170907184745.GA20598@castle.DHCP.thefacebook.com>
References: <20170829100150.4580-1-guro@fb.com>
 <20170829192621.GA5447@cmpxchg.org>
 <20170830105524.GA2852@castle.dhcp.TheFacebook.com>
 <CALvZod5zP=LL=LhD0WX-zX4mPbn7F_obQmpCrrin9YuBQHJLow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CALvZod5zP=LL=LhD0WX-zX4mPbn7F_obQmpCrrin9YuBQHJLow@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, kernel-team@fb.com, LKML <linux-kernel@vger.kernel.org>

On Thu, Sep 07, 2017 at 11:44:12AM -0700, Shakeel Butt wrote:
> >> As far as other types of pages go: page cache and anon are already
> >> batched pretty well, but I think kmem might benefit from this
> >> too. Have you considered using the stock in memcg_kmem_uncharge()?
> >
> > Good idea!
> > I'll try to find an appropriate testcase and check if it really
> > brings any benefits. If so, I'll master a patch.
> >
> 
> Hi Roman, did you get the chance to try this on memcg_kmem_uncharge()?

Hi Shakeel!

Not yet, I'll try to it asap.
Do you have an example when it's costly?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
