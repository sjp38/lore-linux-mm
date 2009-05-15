Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2FFA86B005D
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:55:20 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4FInqFo005030
	for <linux-mm@kvack.org>; Fri, 15 May 2009 12:49:52 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4FIu1rI086780
	for <linux-mm@kvack.org>; Fri, 15 May 2009 12:56:01 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4FIu0Xo013970
	for <linux-mm@kvack.org>; Fri, 15 May 2009 12:56:01 -0600
Date: Fri, 15 May 2009 13:56:02 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 11/11] mm: Convert #ifdef DEBUG printk(KERN_DEBUG to
	pr_debug(
Message-ID: <20090515185602.GA28604@us.ibm.com>
References: <cover.1242407227.git.joe@perches.com> <d2d789905b3ec219d015729a162be7707564fb67.1242407227.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d2d789905b3ec219d015729a162be7707564fb67.1242407227.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, James Morris <jmorris@namei.org>, David Rientjes <rientjes@google.com>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

Quoting Joe Perches (joe@perches.com):
> From: Joe Perches <joe@perches.com>
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Seems reasonable - apart from my woes with dynamic_printk :)

Can you also remove the commented-out '#define DEBUG' line on
line 35 if you haven't already?

Acked-by: Serge Hallyn <serue@us.ibm.com>

thanks,
-serge

> ---
>  mm/oom_kill.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 92bcf1d..8f7fb51 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -159,10 +159,8 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  			points >>= -(p->oomkilladj);
>  	}
> 
> -#ifdef DEBUG
> -	printk(KERN_DEBUG "OOMkill: task %d (%s) got %lu points\n",
> -	p->pid, p->comm, points);
> -#endif
> +	pr_debug("OOMkill: task %d (%s) got %lu points\n",
> +		 p->pid, p->comm, points);
>  	return points;
>  }
> 
> -- 
> 1.6.3.1.9.g95405b.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
