Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9DBE96B003B
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 17:34:27 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so11416002pad.30
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 14:34:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id cz5si10607044pbb.321.2014.04.16.14.34.26
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 14:34:26 -0700 (PDT)
Date: Wed, 16 Apr 2014 14:34:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: memcontrol: remove hierarchy restrictions for
 swappiness and oom_control
Message-Id: <20140416143425.c2b6f511cf4c6cd7336134b3@linux-foundation.org>
In-Reply-To: <1397682798-22906-1-git-send-email-hannes@cmpxchg.org>
References: <1397682798-22906-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 16 Apr 2014 17:13:18 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Per-memcg swappiness and oom killing can currently not be tweaked on a
> memcg that is part of a hierarchy, but not the root of that hierarchy.
> Users have complained that they can't configure this when they turned
> on hierarchy mode.  In fact, with hierarchy mode becoming the default,
> this restriction disables the tunables entirely.
> 
> But there is no good reason for this restriction.  The settings for
> swappiness and OOM killing are taken from whatever memcg whose limit
> triggered reclaim and OOM invocation, regardless of its position in
> the hierarchy tree.
> 
> Allow setting swappiness on any group.  The knob on the root memcg
> already reads the global VM swappiness, make it writable as well.
> 
> Allow disabling the OOM killer on any non-root memcg.

Documentation/cgroups/memory.txt needs updates?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
