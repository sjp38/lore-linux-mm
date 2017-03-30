Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3DC2806CB
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 12:48:57 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id b74so15810756iod.12
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 09:48:57 -0700 (PDT)
Received: from mail-pg0-x236.google.com (mail-pg0-x236.google.com. [2607:f8b0:400e:c05::236])
        by mx.google.com with ESMTPS id e20si3242723iof.161.2017.03.30.09.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 09:48:56 -0700 (PDT)
Received: by mail-pg0-x236.google.com with SMTP id 81so45207559pgh.2
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 09:48:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170330155123.GA3929@cmpxchg.org>
References: <20170317231636.142311-1-timmurray@google.com> <20170330155123.GA3929@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 30 Mar 2017 09:48:55 -0700
Message-ID: <CALvZod7Dr+YaYcSpUYCMAjotnU4hH=TnZWaL6mbBzLq=O3GJTA@mail.gmail.com>
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, surenb@google.com, totte@google.com, kernel-team@android.com

> A more useful metric for memory pressure at this point is quantifying
> that time you spend thrashing: time the job spends in direct reclaim
> and on the flipside time the job waits for recently evicted pages to
> come back. Combined, that gives you a good measure of overhead from
> memory pressure; putting that in relation to a useful baseline of
> meaningful work done gives you a portable scale of how effictively
> your job is running.
>
> I'm working on that right now, hopefully I'll have something useful
> soon.

Johannes, is the work you are doing only about file pages or will it
equally apply to anon pages as well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
