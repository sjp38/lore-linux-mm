Return-Path: <SRS0=dvGr=TS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9D9BC04AB4
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 01:19:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60C0821848
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 01:19:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Aa2aThr8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60C0821848
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2C336B0003; Fri, 17 May 2019 21:19:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDCDD6B0005; Fri, 17 May 2019 21:19:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCB976B0006; Fri, 17 May 2019 21:19:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id BCF3B6B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 21:19:32 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id d10so7822874ybn.23
        for <linux-mm@kvack.org>; Fri, 17 May 2019 18:19:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7Ho8cHrK4qMqiN3LtaRzVtq4HS5hpwx3f8cFy/TZJ4Y=;
        b=RI6bkvpsBMXsfBr9xkqhhupU3KiPMIQtHu4dOYOkdF5aLUCCe6cdDbUAcQbdLk+WnX
         +wpHTCk4XYDyfo04DK30hfeDIQt7t3PczVQIoAW7itTDXZJdnp1VOeWbPQ2KbHPXzV64
         ZMmtm4IkzcdHzkghRfEXbrRkO9uciRamjB1tl/O65bROeo0hTdtpkb4TJzagbT9ndZ53
         E29qrZBCcgesqoFvpyABx9dCcSDuxyea0drST1bfIefi9mCOc4iqTgZZSWSaW/wTMz6+
         43e7BFPKsuU5QlwuL+Oj1zfXXJ/kMiE/R4qX0Sy8NyLgtuzwH5cssOE6/nMvXySFMWa3
         dl/w==
X-Gm-Message-State: APjAAAV7tOka7DRNCL/XYFhEtE1hugjv2aMZR7+hfOc2saMp7avMF7De
	chBEq9WGNUbIsJf0JXZh/FhJuXKv5LDY6ZE9gJzCboWaO1yoYhQ+1sxy1fDffbDWMVDA+eG52ug
	+cTfzler8u9io1PhsL3SfmZLWWsuwtykBtlfW3IJoFNMLQV53THmBa+17Yk2pAi+lwQ==
X-Received: by 2002:a25:77c8:: with SMTP id s191mr6704380ybc.152.1558142372472;
        Fri, 17 May 2019 18:19:32 -0700 (PDT)
X-Received: by 2002:a25:77c8:: with SMTP id s191mr6704362ybc.152.1558142371893;
        Fri, 17 May 2019 18:19:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558142371; cv=none;
        d=google.com; s=arc-20160816;
        b=R+iXDRRJFU2wkPimjK8Bl0/0uWPlN7ehc2pRhCoBYJ+0CCo9VkJlCBxVFe8mCh+0or
         DAZ4fIGTMmX1B9gFzecYkMPNHONy3lLhZXSEmbcNicqyT90/+26QkRfahp1A1ULExNuk
         uSMPcrStU91jRJMl5uK78MbgBOoc5ixjusEZbDGMwtfUIUxY8QxQ0WPgEtgud4BIPaC4
         VjaHjZodncKX17lipzkCWH/5EVj5d215w8jPG+NILfZhKZv7chxW6WaatKmyGebBWkP8
         bQhnXTVpy25k1eg4tjrvxI917BoLqzLHufw+peBj2jB5HePQrQ7zo536Tdbt4qhkqBAV
         Do5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7Ho8cHrK4qMqiN3LtaRzVtq4HS5hpwx3f8cFy/TZJ4Y=;
        b=Tp3Q0CAltW2kzhZHIVaIdq8anPAZRXpaRu43agcFQ9ZcCjdvAzj5zcOb2q61THAYnP
         /4AZcLtL7lRiaQ/Pg41+GLepbC1803UjzhfG9agHebc3k56+Nuuhj9iJTzj3v+cV8Va/
         sRRPSlzoX7xtdab6G7eGbooMZiNbfVM1a415RUyjqtSCePtBLKQdQadn0DVwP4yRUTzs
         r3Ncmhlmsc/0rUizST84DOu+IF+G5PZ8bWafJPtM5EoS2it+7qY34WO10jRndmBHNcx2
         NAT6ru3XnmaboqY7i99BZlX1kgDe71CbbQU8R1/EWHci3iqbSm5Yci5S7nRhMUZTKaSd
         it4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Aa2aThr8;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q130sor4208963ybb.142.2019.05.17.18.19.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 18:19:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Aa2aThr8;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7Ho8cHrK4qMqiN3LtaRzVtq4HS5hpwx3f8cFy/TZJ4Y=;
        b=Aa2aThr8oZpP0WVahD8NCNtshzOd5qsE6LqKaPa6VLI3iYk06oUL4BlBH5BA18zwU4
         Gq3Rt3R6ehByjfoq9VBjVL/B24UpZw5SethE0DegFvSksoigMBv9jPJcnkpsG7vVKnei
         7eB9NigP6sVXiyh6W3xmHGF2LtlTntNh8IWQG1gltDpbv/Vnqwt/dDkSv32UQ+Zyvmuj
         7W64PTuAiZN+TtH90+krk10ZQRyYxIinqRqWZJElqdKAXDdwkbAtXLjE7EHAVHb0pNoh
         RHgbOyZnzTbbTsUszgg8DRq5iAKYSjwFf09KEFH7+p2jQNeUpkR8kOulHqKzRSL9pd69
         RqIw==
X-Google-Smtp-Source: APXvYqzvKyMFNOSqSc71NU74orRIuvu6avgzOT91rXMBDzXJ82LO1zMIoynfnQdIB73p8+SDOiYAK9X4zzYXERAIrcA=
X-Received: by 2002:a25:8608:: with SMTP id y8mr28856096ybk.100.1558142371276;
 Fri, 17 May 2019 18:19:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190518001818.193336-1-shakeelb@google.com> <20190518005927.GB3431@tower.DHCP.thefacebook.com>
In-Reply-To: <20190518005927.GB3431@tower.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 17 May 2019 18:19:19 -0700
Message-ID: <CALvZod4cOWrzGzJncCzaPqBbnmavbkrbTZnwY6r1V5eFVwOJAQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm, memcg: introduce memory.events.local
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Chris Down <chris@chrisdown.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 5:59 PM Roman Gushchin <guro@fb.com> wrote:
>
> On Fri, May 17, 2019 at 05:18:18PM -0700, Shakeel Butt wrote:
> > The memory controller in cgroup v2 exposes memory.events file for each
> > memcg which shows the number of times events like low, high, max, oom
> > and oom_kill have happened for the whole tree rooted at that memcg.
> > Users can also poll or register notification to monitor the changes in
> > that file. Any event at any level of the tree rooted at memcg will
> > notify all the listeners along the path till root_mem_cgroup. There are
> > existing users which depend on this behavior.
> >
> > However there are users which are only interested in the events
> > happening at a specific level of the memcg tree and not in the events in
> > the underlying tree rooted at that memcg. One such use-case is a
> > centralized resource monitor which can dynamically adjust the limits of
> > the jobs running on a system. The jobs can create their sub-hierarchy
> > for their own sub-tasks. The centralized monitor is only interested in
> > the events at the top level memcgs of the jobs as it can then act and
> > adjust the limits of the jobs. Using the current memory.events for such
> > centralized monitor is very inconvenient. The monitor will keep
> > receiving events which it is not interested and to find if the received
> > event is interesting, it has to read memory.event files of the next
> > level and compare it with the top level one. So, let's introduce
> > memory.events.local to the memcg which shows and notify for the events
> > at the memcg level.
> >
> > Now, does memory.stat and memory.pressure need their local versions.
> > IMHO no due to the no internal process contraint of the cgroup v2. The
> > memory.stat file of the top level memcg of a job shows the stats and
> > vmevents of the whole tree. The local stats or vmevents of the top level
> > memcg will only change if there is a process running in that memcg but
> > v2 does not allow that. Similarly for memory.pressure there will not be
> > any process in the internal nodes and thus no chance of local pressure.
> >
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
> > ---
> > Changelog since v1:
> > - refactor memory_events_show to share between events and events.local
>
> Reviewed-by: Roman Gushchin <guro@fb.com>
>
> You also need to add some stuff into cgroup v2 documentation.
>

Thanks, will update the doc in the next version.

Shakeel

