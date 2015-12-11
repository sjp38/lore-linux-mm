Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4696B0259
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:43:08 -0500 (EST)
Received: by wmec201 with SMTP id c201so84406500wme.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:43:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lf9si27560502wjc.180.2015.12.11.11.43.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 11:43:07 -0800 (PST)
Date: Fri, 11 Dec 2015 14:42:54 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 7/7] Documentation: cgroup: add memory.swap.{current,max}
 description
Message-ID: <20151211194254.GF3773@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <24930f544e7e98a23a17c9adcacb9397b1b8cae7.1449742561.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24930f544e7e98a23a17c9adcacb9397b1b8cae7.1449742561.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 10, 2015 at 02:39:20PM +0300, Vladimir Davydov wrote:
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Can we include a blurb for R-5-1 of cgroups.txt as well to explain why
cgroup2 has a new swap interface? I had already written something up
in the past, pasted below, feel free to use it if you like. Otherwise,
you had pretty good reasons in your swap controller changelog as well.

---

- The combined memory+swap accounting and limiting is replaced by real
  control over swap space.

  memory.swap.current

       The amount memory of this subtree that has been swapped to
       disk.

  memory.swap.max

       The maximum amount of memory this subtree is allowed to swap
       to disk.

  The main argument for a combined memory+swap facility in the
  original cgroup design was that global or parental pressure would
  always be able to swap all anonymous memory of a child group,
  regardless of the child's own (possibly untrusted) configuration.
  However, untrusted groups can sabotage swapping by other means--such
  as referencing its anonymous memory in a tight loop--and an admin
  can not assume full swappability when overcommitting untrusted jobs.

  For trusted jobs, on the other hand, a combined counter is not an
  intuitive userspace interface, and it flies in the face of the idea
  that cgroup controllers should account and limit specific physical
  resources. Swap space is a resource like all others in the system,
  and that's why unified hierarchy allows distributing it separately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
