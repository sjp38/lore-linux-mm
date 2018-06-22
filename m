Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFEE66B000E
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 15:00:00 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f5-v6so4076962plf.18
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 12:00:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j21-v6sor2214310pfk.151.2018.06.22.11.59.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 11:59:59 -0700 (PDT)
Date: Fri, 22 Jun 2018 11:59:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] mm,oom: Simplify exception case handling in
 out_of_memory().
In-Reply-To: <1528369223-7571-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.21.1806221159450.110785@chino.kir.corp.google.com>
References: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <1528369223-7571-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu, 7 Jun 2018, Tetsuo Handa wrote:

> To avoid oversights when adding the "mm, oom: cgroup-aware OOM killer"
> patchset, simplify the exception case handling in out_of_memory().
> This patch makes no functional changes.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>

Acked-by: David Rientjes <rientjes@google.com>
