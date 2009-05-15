Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A85BB6B006A
	for <linux-mm@kvack.org>; Fri, 15 May 2009 15:40:10 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id n4FJeZHv021546
	for <linux-mm@kvack.org>; Fri, 15 May 2009 12:40:35 -0700
Received: from pxi37 (pxi37.prod.google.com [10.243.27.37])
	by wpaz17.hot.corp.google.com with ESMTP id n4FJeXqv011112
	for <linux-mm@kvack.org>; Fri, 15 May 2009 12:40:33 -0700
Received: by pxi37 with SMTP id 37so1211177pxi.11
        for <linux-mm@kvack.org>; Fri, 15 May 2009 12:40:33 -0700 (PDT)
Date: Fri, 15 May 2009 12:40:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 11/11] mm: Convert #ifdef DEBUG printk(KERN_DEBUG to
 pr_debug(
In-Reply-To: <d2d789905b3ec219d015729a162be7707564fb67.1242407227.git.joe@perches.com>
Message-ID: <alpine.DEB.2.00.0905151240080.925@chino.kir.corp.google.com>
References: <cover.1242407227.git.joe@perches.com> <d2d789905b3ec219d015729a162be7707564fb67.1242407227.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, James Morris <jmorris@namei.org>, Serge Hallyn <serue@us.ibm.com>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 May 2009, Joe Perches wrote:

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

You can just remove the entire printk() since this information is now 
exported via /proc/pid/oom_score.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
