Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AB5976B0006
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:17:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x203-v6so5539954wmg.8
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:17:08 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w27-v6si3745516edl.174.2018.06.11.07.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:17:07 -0700 (PDT)
Date: Mon, 11 Jun 2018 10:19:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: fix null pointer dereference in mem_cgroup_protected
Message-ID: <20180611141925.GC1507@cmpxchg.org>
References: <20180608170607.29120-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180608170607.29120-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

On Fri, Jun 08, 2018 at 06:06:07PM +0100, Roman Gushchin wrote:
> Shakeel reported a crash in mem_cgroup_protected(), which
> can be triggered by memcg reclaim if the legacy cgroup v1
> use_hierarchy=0 mode is used:
...
> Reported-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
