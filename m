Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D08F46B0264
	for <linux-mm@kvack.org>; Fri,  6 May 2016 17:47:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m64so45806731lfd.1
        for <linux-mm@kvack.org>; Fri, 06 May 2016 14:47:27 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id wa2si20778349wjc.62.2016.05.06.14.47.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 14:47:26 -0700 (PDT)
Date: Fri, 6 May 2016 17:45:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: fix stale mem_cgroup_force_empty() comment
Message-ID: <20160506214534.GA9768@cmpxchg.org>
References: <1462569810-54496-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462569810-54496-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 06, 2016 at 02:23:30PM -0700, Greg Thelen wrote:
> commit f61c42a7d911 ("memcg: remove tasks/children test from
> mem_cgroup_force_empty()") removed memory reparenting from the function.
> 
> Fix the function's comment.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
