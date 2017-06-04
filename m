Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF8E26B02C3
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 15:39:59 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b72so2705871lfe.4
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 12:39:59 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id 21si2304930ljj.211.2017.06.04.12.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 12:39:58 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id v20so5234734lfa.2
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 12:39:58 -0700 (PDT)
Date: Sun, 4 Jun 2017 22:39:54 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [RFC PATCH v2 5/7] mm, oom: introduce oom_score_adj for memory
 cgroups
Message-ID: <20170604193954.GC19980@esperanza>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
 <1496342115-3974-6-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496342115-3974-6-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 01, 2017 at 07:35:13PM +0100, Roman Gushchin wrote:
> Introduce a per-memory-cgroup oom_score_adj setting.
> A read-write single value file which exits on non-root
> cgroups. The default is "0".
> 
> It will have a similar meaning to a per-process value,
> available via /proc/<pid>/oom_score_adj.
> Should be in a range [-1000, 1000].

IMHO OOM scoring (not only the user API, but the logic as well) should
be introduced by a separate patch following the main one (#6) in the
series. Rationale: we might want to commit the main patch right away,
while postponing OOM scoring for later, because some people might find
the API controversial and needing a further, deeper discussion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
