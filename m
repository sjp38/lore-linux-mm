Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7753C6B0007
	for <linux-mm@kvack.org>; Tue, 29 May 2018 04:31:55 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id a7-v6so12366341wrq.13
        for <linux-mm@kvack.org>; Tue, 29 May 2018 01:31:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a32-v6si2356616ede.30.2018.05.29.01.31.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 May 2018 01:31:54 -0700 (PDT)
Date: Tue, 29 May 2018 10:31:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: force charge kmem counter too
Message-ID: <20180529083153.GR27180@dhcp22.suse.cz>
References: <20180525185501.82098-1-shakeelb@google.com>
 <20180526185144.xvh7ejlyelzvqwdb@esperanza>
 <CALvZod5yTxcuB_Aao-a0ChNEnwyBJk9UPvEQ80s9tZFBQ0cxpw@mail.gmail.com>
 <20180528091110.GG1517@dhcp22.suse.cz>
 <CALvZod6x5iRmcJ6pYKS+jwJd855jnwmVcPK9tnKbuJ9Hfppa-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod6x5iRmcJ6pYKS+jwJd855jnwmVcPK9tnKbuJ9Hfppa-A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 28-05-18 10:23:07, Shakeel Butt wrote:
> On Mon, May 28, 2018 at 2:11 AM, Michal Hocko <mhocko@kernel.org> wrote:
> Though is there a precedence where the broken feature is not fixed
> because an alternative is available?

Well, I can see how breaking GFP_NOFAIL semantic is problematic, on the
other hand we keep saying that kmem accounting in v1 is hard usable and
strongly discourage people from using it. Sure we can add the code which
handles _this_ particular case but that wouldn't make the whole thing
more usable I strongly suspect. Maybe I am wrong and you can provide
some specific examples. Is GFP_NOFAIL that common to matter?

In any case we should balance between the code maintainability here.
Adding more cruft into the allocator path is not free.

-- 
Michal Hocko
SUSE Labs
