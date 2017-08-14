Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 723076B02B4
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:44:07 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u199so159268013pgb.13
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:44:07 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id e8si5253724pln.721.2017.08.14.15.44.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 15:44:06 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id l64so55665248pge.5
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:44:06 -0700 (PDT)
Date: Mon, 14 Aug 2017 15:44:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v5 3/4] mm, oom: introduce oom_priority for memory cgroups
In-Reply-To: <20170814183213.12319-4-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1708141543500.63207@chino.kir.corp.google.com>
References: <20170814183213.12319-1-guro@fb.com> <20170814183213.12319-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 14 Aug 2017, Roman Gushchin wrote:

> Introduce a per-memory-cgroup oom_priority setting: an integer number
> within the [-10000, 10000] range, which defines the order in which
> the OOM killer selects victim memory cgroups.
> 
> OOM killer prefers memory cgroups with larger priority if they are
> populated with elegible tasks.
> 
> The oom_priority value is compared within sibling cgroups.
> 
> The root cgroup has the oom_priority 0, which cannot be changed.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org

Tested-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
