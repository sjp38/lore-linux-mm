Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CDA276B02F1
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 16:48:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p87so9045302pfj.4
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 13:48:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j1sor4361483pgn.89.2017.09.11.13.48.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 13:48:40 -0700 (PDT)
Date: Mon, 11 Sep 2017 13:48:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 3/4] mm, oom: add cgroup v2 mount option for cgroup-aware
 OOM killer
In-Reply-To: <20170911131742.16482-4-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1709111345320.102819@chino.kir.corp.google.com>
References: <20170911131742.16482-1-guro@fb.com> <20170911131742.16482-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 11 Sep 2017, Roman Gushchin wrote:

> Add a "groupoom" cgroup v2 mount option to enable the cgroup-aware
> OOM killer. If not set, the OOM selection is performed in
> a "traditional" per-process way.
> 
> The behavior can be changed dynamically by remounting the cgroupfs.

I can't imagine that Tejun would be happy with a new mount option, 
especially when it's not required.

OOM behavior does not need to be defined at mount time and for the entire 
hierarchy.  It's possible to very easily implement a tunable as part of 
mem cgroup that is propagated to descendants and controls the oom scoring 
behavior for that hierarchy.  It does not need to be system wide and 
affect scoring of all processes based on which mem cgroup they are 
attached to at any given time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
