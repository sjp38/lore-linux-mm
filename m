Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE13B6B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 18:45:06 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id h33so4122848wrh.10
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 15:45:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u13si11747wmd.165.2018.03.08.15.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 15:45:05 -0800 (PST)
Date: Thu, 8 Mar 2018 15:45:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: memcg: expose mem_cgroup_put API
Message-Id: <20180308154501.a42bb22af0da6ccd727773c8@linux-foundation.org>
In-Reply-To: <20180308024850.39737-1-shakeelb@google.com>
References: <20180308024850.39737-1-shakeelb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, David Rientjes <rientjes@google.com>

On Wed,  7 Mar 2018 18:48:50 -0800 Shakeel Butt <shakeelb@google.com> wrote:

> This patch exports mem_cgroup_put API to put the refcnt of the memory
> cgroup.

OK, I remember now.  This is intended to make
fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch independent of
mm-oom-cgroup-aware-oom-killer.patch by extracting mem_cgroup_put()
from mm-oom-cgroup-aware-oom-killer.patch.

However it will not permit me to stage
fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch ahead of
mm-oom-cgroup-aware-oom-killer.patch because there are quite a lot of
syntactic clashes.

I can resolve those if needed, but am keenly hoping that the
mm-oom-cgroup-aware-oom-killer.patch issues are resolved soon so there
isn't a need to do this.
