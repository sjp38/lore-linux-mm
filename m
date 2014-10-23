Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id CE41A6B006E
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 14:19:39 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id q1so1354044lam.36
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 11:19:37 -0700 (PDT)
Received: from gum.cmpxchg.org ([85.214.110.215])
        by mx.google.com with ESMTPS id ld12si3779974lac.105.2014.10.23.11.19.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 11:19:35 -0700 (PDT)
Date: Thu, 23 Oct 2014 14:19:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: Fix NULL pointer deref in task_in_mem_cgroup()
Message-ID: <20141023181929.GB15937@phnom.home.cmpxchg.org>
References: <1414082865-4091-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414082865-4091-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 23, 2014 at 06:47:45PM +0200, Jan Kara wrote:
> 'curr' pointer in task_in_mem_cgroup() can be NULL when we race with
> somebody clearing task->mm. Check for it before dereferencing the
> pointer.

If task->mm is already NULL, we fall back to mem_cgroup_from_task(),
which definitely returns a memcg unless you pass NULL in there.  So I
don't see how that could happen, and the NULL checks in the fallback
branch as well as in __mem_cgroup_same_or_subtree seem bogus to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
