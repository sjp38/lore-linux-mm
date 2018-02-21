Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 848596B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 12:57:51 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id r1so2317650ioa.0
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 09:57:51 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id g1si18563586itd.56.2018.02.21.09.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 09:57:50 -0800 (PST)
Date: Wed, 21 Feb 2018 11:57:47 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 0/3] Directed kmem charging
In-Reply-To: <CALvZod68LD-wnbm2+MQks=bd_D2zY64uScUBp28hyug_vaGyDA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1802211155500.13845@nuc-kabylake>
References: <20180221030101.221206-1-shakeelb@google.com> <alpine.DEB.2.20.1802211002200.12567@nuc-kabylake> <CALvZod68LD-wnbm2+MQks=bd_D2zY64uScUBp28hyug_vaGyDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 21 Feb 2018, Shakeel Butt wrote:

> On Wed, Feb 21, 2018 at 8:09 AM, Christopher Lameter <cl@linux.com> wrote:
> > Another way to solve this is to switch the user context right?
> >
> > Isnt it possible to avoid these patches if do the allocation in another
> > task context instead?
> >
>
> Sorry, can you please explain what you mean by 'switch the user
> context'. Is there any example in kernel which does something similar?

See include/linux/task_work.h. One use case is in mntput_no_expire() in
linux/fs/namespace.c

> > Are there really any other use cases beyond fsnotify?
> >
>
> Another use case I have in mind and plan to upstream is to bind a
> filesystem mount with a memcg. So, all the file pages (or anon pages
> for shmem) and kmem (like inodes and dentry) will be charged to that
> memcg.

The mount logic already uses task_work.h. That may be the approach to
expand there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
