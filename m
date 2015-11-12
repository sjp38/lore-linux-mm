Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA3E6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 05:26:54 -0500 (EST)
Received: by wmww144 with SMTP id w144so194076137wmw.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 02:26:53 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id n19si17756168wjr.18.2015.11.12.02.26.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 02:26:53 -0800 (PST)
Received: by wmec201 with SMTP id c201so84509088wme.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 02:26:52 -0800 (PST)
Date: Thu, 12 Nov 2015 11:26:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/5] mm: use KERN_DEBUG for dump_stack() during an OOM
Message-ID: <20151112102651.GF1174@dhcp22.suse.cz>
References: <20151105223014.701269769@redhat.com>
 <20151105223014.964111331@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105223014.964111331@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aris@redhat.com
Cc: linux-kerne@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

[Hmm, this got stuck in my outgoing queue for some reason - sending
again]

On Thu 05-11-15 17:30:19, aris@redhat.com wrote:
> dump_stack() isn't always useful and in some scenarios OOMs can be quite
> common and there's no need to flood the console with dump_stack()'s output.

I think we want to revisit loglevel of other parts of the oom report as
well but this is a good start.

> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Aristeu Rozanski <aris@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> 
> ---
>  mm/oom_kill.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2.6.orig/mm/oom_kill.c	2015-10-27 09:24:01.014413690 -0400
> +++ linux-2.6/mm/oom_kill.c	2015-11-05 14:51:31.091521337 -0500
> @@ -384,7 +384,7 @@ pr_warning("%s invoked oom-killer: gfp_m
>  		current->signal->oom_score_adj);
>  	cpuset_print_task_mems_allowed(current);
>  	task_unlock(current);
> -	dump_stack();
> +	dump_stack_lvl(KERN_DEBUG);
>  	if (memcg)
>  		mem_cgroup_print_oom_info(memcg, p);
>  	else

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
