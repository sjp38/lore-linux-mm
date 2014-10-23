Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD626B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 14:34:39 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id ge10so1370697lab.38
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 11:34:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k3si3868057laf.77.2014.10.23.11.34.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 11:34:37 -0700 (PDT)
Date: Thu, 23 Oct 2014 20:34:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] memcg: Fix NULL pointer deref in task_in_mem_cgroup()
Message-ID: <20141023183435.GD21034@quack.suse.cz>
References: <1414082865-4091-1-git-send-email-jack@suse.cz>
 <20141023181929.GB15937@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141023181929.GB15937@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu 23-10-14 14:19:29, Johannes Weiner wrote:
> On Thu, Oct 23, 2014 at 06:47:45PM +0200, Jan Kara wrote:
> > 'curr' pointer in task_in_mem_cgroup() can be NULL when we race with
> > somebody clearing task->mm. Check for it before dereferencing the
> > pointer.
> 
> If task->mm is already NULL, we fall back to mem_cgroup_from_task(),
> which definitely returns a memcg unless you pass NULL in there.  So I
> don't see how that could happen, and the NULL checks in the fallback
> branch as well as in __mem_cgroup_same_or_subtree seem bogus to me.
  OK, I admittedly don't understand that code much. I was just wondering
that we check 'curr' for being NULL in all the places except for that one
which looked suspicious... If curr cannot be NULL, then we should just
remove those checks I assume.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
