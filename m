Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E60126B0038
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 00:43:07 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id g10so2811113pdj.13
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 21:43:07 -0700 (PDT)
Date: Wed, 5 Jun 2013 21:43:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] arch: invoke oom-killer from page fault
In-Reply-To: <20130606043620.GA9406@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1306052142490.27104@chino.kir.corp.google.com>
References: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org> <alpine.DEB.2.02.1306052053360.25115@chino.kir.corp.google.com> <20130606043620.GA9406@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 6 Jun 2013, Johannes Weiner wrote:

> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: invoke oom-killer from remaining unconverted page fault
>  handlers
> 
> A few remaining architectures directly kill the page faulting task in
> an out of memory situation.  This is usually not a good idea since
> that task might not even use a significant amount of memory and so may
> not be the optimal victim to resolve the situation.
> 
> Since '1c0fe6e mm: invoke oom-killer from page fault' (2.6.29) there
> is a hook that architecture page fault handlers are supposed to call
> to invoke the OOM killer and let it pick the right task to kill.
> Convert the remaining architectures over to this hook.
> 
> To have the previous behavior of simply taking out the faulting task
> the vm.oom_kill_allocating_task sysctl can be set to 1.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
