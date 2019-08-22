Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8FE8C3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:55:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C9622133F
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:55:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="FYT0lQV4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C9622133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1F756B0326; Thu, 22 Aug 2019 10:55:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD0966B0327; Thu, 22 Aug 2019 10:55:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C98406B0328; Thu, 22 Aug 2019 10:55:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0185.hostedemail.com [216.40.44.185])
	by kanga.kvack.org (Postfix) with ESMTP id A79686B0326
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:55:53 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 41D318125
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:55:53 +0000 (UTC)
X-FDA: 75850363386.07.uncle46_6d8179f4ede49
X-HE-Tag: uncle46_6d8179f4ede49
X-Filterd-Recvd-Size: 5741
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com [209.85.166.67])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:55:52 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id p12so12453689iog.5
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:55:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Q0wZh/4eoEqPIOzqTZqYPWLyH+hmBcAleu6hn0qpR1E=;
        b=FYT0lQV4jyIvhIYQEmusX9xZ6+PljzPQLO5A6kRdIxSmSntvCyp+oIozq0QbcobPm0
         U+n09xGdumBz3idw8/NbVLvhZima8AHwuZyYxthJPW7w33MQAB++LXepHo5AJv0mRYjg
         VMzOsk6/yhFIgLaavspEQnZNQzeZfkKGf5RDH2DTgt7p2Ojpt4kxjzwv6GrNdd8YnDmy
         b8sy1sReUILgJvjsNVSWDrN1a/eKfy0O6tT69sflIow4VUzC+hFCCg6d/Y3LnF6VFxgo
         /vDvOVQkvoTYJZMEmtqI/YYwZ8j6S9Ig2VJiNr1kV1FwQlK1eMw5w5yc5NTQEeugzctm
         jfYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Q0wZh/4eoEqPIOzqTZqYPWLyH+hmBcAleu6hn0qpR1E=;
        b=p5mmklphTC0cREBEfKLQDTVAh7Vvvw7na99a4Ry5RlAvCR06aB6hI7KAK390yofwdR
         dzHcYd6VktyKRwmyhzOKGZlphUcYnG3cpLtp7DEaIYK+s1ghhY+8M6TKfFcPaNuQEF0j
         AqRdvhSQC+PEYr83IRU0jFt+4DUl890sqqUENutCr9eB/cHZFeOmKIRABLbH4d/0PzEi
         4zS1JiW+oxqzACgLaebjrmrRm2gEtxYfIuDLGAkZEXHIOpYfPfmujDclCT6DNZo5JTG+
         3vDvvQ/0wrg2fTJ2sYkwMfO/ZIa5XmMCOv0DYKFF5D7jI15qlGdlkfBmyBPfeNPjEORN
         lE9A==
X-Gm-Message-State: APjAAAVM+tdUJ0VQ8r8KAU1QH+Wodwo6DrnpV9xAUBQMOIccWKQGAytU
	6JycdTfOhjsboK4JubFy7JhXAErRDJ6XVxG+NqHsyQ==
X-Google-Smtp-Source: APXvYqy5AZAJmwouZteRGWOXLWbdOyLehNERePxTeUACR/e5Q5nCRTooG/TRmy2DbZbovwqmENfGImoE8GJYUGNCEsE=
X-Received: by 2002:a5e:8e0d:: with SMTP id a13mr122437ion.28.1566485751848;
 Thu, 22 Aug 2019 07:55:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190821001445.32114-1-echron@arista.com> <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
 <20190821064732.GW3111@dhcp22.suse.cz> <alpine.DEB.2.21.1908210017320.177871@chino.kir.corp.google.com>
 <20190821074721.GY3111@dhcp22.suse.cz> <CAM3twVR5Z1LG4+pqMF94mCw8R0sJ3VJtnggQnu+047c7jxJVug@mail.gmail.com>
 <20190822072134.GD12785@dhcp22.suse.cz>
In-Reply-To: <20190822072134.GD12785@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Thu, 22 Aug 2019 07:55:40 -0700
Message-ID: <CAM3twVQuMU+T+GveqyMuyedcOC+NGrb7QNJCsHXRk3eVCfNG0w@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: Add oom_score_adj value to oom Killed process message
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 12:21 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 21-08-19 16:12:08, Edward Chron wrote:
> [...]
> > Additionally (which you know, but mentioning for reference) the OOM
> > output used to look like this:
> >
> > Nov 14 15:23:48 oldserver kernel: [337631.991218] Out of memory: Kill
> > process 19961 (python) score 17 or sacrifice child
> > Nov 14 15:23:48 oldserver kernel: [337631.991237] Killed process 31357
> > (sh) total-vm:5400kB, anon-rss:252kB, file-rss:4kB, shmem-rss:0kB
> >
> > It now looks like this with 5.3.0-rc5 (minus the oom_score_adj):
> >
> > Jul 22 10:42:40 newserver kernel:
> > oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0,global_oom,task_memcg=/user.slice/user-10383.slice/user@10383.service,task=oomprocs,pid=3035,uid=10383
> > Jul 22 10:42:40 newserver kernel: Out of memory: Killed process 3035
> > (oomprocs) total-vm:1056800kB, anon-rss:8kB, file-rss:4kB,
> > shmem-rss:0kB
> > Jul 22 10:42:40 newserver kernel: oom_reaper: reaped process 3035
> > (oomprocs), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> >
> > The old output did explain that a oom_score of 17 must have either
> > tied for highest or was the highest.
> > This did document why OOM selected the process it did, even if ends up
> > killing the related sh process.
> >
> > With the newer format that added constraint message, it does provide
> > uid which can be helpful and
> > the oom_reaper showing that the memory was reclaimed is certainly reassuring.
> >
> > My understanding now is that printing the oom_score is discouraged.
> > This seems unfortunate.  The oom_score_adj can be adjusted
> > appropriately if oom_score is known.
> > So It would be useful to have both.
>
> As already mentioned in our previous discussion I am really not happy
> about exporting oom_score withtout a larger context - aka other tasks
> scores to have something to compare against. Other than that the value
> is an internal implementation detail and it is meaningless without
> knowing the exact algorithm which can change at any times so no
> userspace should really depend on it. All important metrics should be
> displayed by the oom report message already.

The oom_score is no longer displayed any where in the OOM output with 5.3
so there isn't anything to compare against any way with the current OOM
per process output and for the killed process.

I understand the reasoning for this from your discussion.
Thanks for explaining the rational.

>
> --
> Michal Hocko
> SUSE Labs

