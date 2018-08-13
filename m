Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id B8FE36B0003
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 09:48:46 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b141-v6so22095170ywh.12
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 06:48:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o128-v6sor3961462ywf.194.2018.08.13.06.48.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Aug 2018 06:48:45 -0700 (PDT)
Date: Mon, 13 Aug 2018 06:48:42 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC 1/3] cgroup: list all subsystem states in debugfs
 files
Message-ID: <20180813134842.GF3978217@devbig004.ftw2.facebook.com>
References: <153414348591.737150.14229960913953276515.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153414348591.737150.14229960913953276515.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Konstantin.

On Mon, Aug 13, 2018 at 09:58:05AM +0300, Konstantin Khlebnikov wrote:
> After removing cgroup subsystem state could leak or live in background
> forever because it is pinned by some reference. For example memory cgroup
> could be pinned by pages in cache or tmpfs.
> 
> This patch adds common debugfs interface for listing basic state for each
> controller. Controller could define callback for dumping own attributes.
> 
> In file /sys/kernel/debug/cgroup/<controller> each line shows state in
> format: <common_attr>=<value>... [-- <controller_attr>=<value>... ]

Seems pretty useful to me.  Roman, Johannes, what do you guys think?

Thanks.

-- 
tejun
