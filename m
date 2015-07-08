Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 773FB6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 19:36:16 -0400 (EDT)
Received: by iecvh10 with SMTP id vh10so166403478iec.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:36:16 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id n6si3973612igx.49.2015.07.08.16.36.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 16:36:15 -0700 (PDT)
Received: by igcqs7 with SMTP id qs7so68101533igc.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:36:15 -0700 (PDT)
Date: Wed, 8 Jul 2015 16:36:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] oom: Do not panic when OOM killer is sysrq
 triggered
In-Reply-To: <1436360661-31928-2-git-send-email-mhocko@suse.com>
Message-ID: <alpine.DEB.2.10.1507081635030.16585@chino.kir.corp.google.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com> <1436360661-31928-2-git-send-email-mhocko@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 8 Jul 2015, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.cz>
> 
> OOM killer might be triggered explicitly via sysrq+f. This is supposed
> to kill a task no matter what e.g. a task is selected even though there
> is an OOM victim on the way to exit. This is a big hammer for an admin
> to help to resolve a memory short condition when the system is not able
> to cope with it on its own in a reasonable time frame (e.g. when the
> system is trashing or the OOM killer cannot make sufficient progress)
> 
> E.g. it doesn't make any sense to obey panic_on_oom setting because
> a) administrator could have used other sysrqs to achieve the
> panic/reboot and b) the policy would break an existing usecase to
> kill a memory hog which would be recoverable unlike the panic which
> might be configured for the real OOM condition.
> 
> It also doesn't make much sense to panic the system when there is no
> OOM killable task because administrator might choose to do additional
> steps before rebooting/panicking the system.
> 
> While we are there also add a comment explaining why
> sysctl_oom_kill_allocating_task doesn't apply to sysrq triggered OOM
> killer even though there is no explicit check and we subtly rely
> on current->mm being NULL for the context from which it is triggered.
> 
> Also be more explicit about sysrq+f behavior in the documentation.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Nack, this is already handled by patch 2 in my series.  I understand that 
the titles were wrong for patches 2 and 3, but it doesn't mean we need to 
add hacks around the code before organizing this into struct oom_control 
or completely pointless comments and printks that will fill the kernel 
log.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
