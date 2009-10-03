Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2FD60021D
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 03:40:06 -0400 (EDT)
Subject: Re: [patch] procfs: provide stack information for threads
From: Stefani Seibold <stefani@seibold.net>
In-Reply-To: <m263axq8ie.fsf@whitebox.home>
References: <1238511505.364.61.camel@matrix>
	 <20090401193135.GA12316@elte.hu> <1244146873.20012.6.camel@wall-e>
	 <m2eipl7axx.fsf@igel.home> <m2ws3djwrr.fsf@igel.home>
	 <m263axq8ie.fsf@whitebox.home>
Content-Type: text/plain
Date: Sat, 03 Oct 2009 09:40:26 +0200
Message-Id: <1254555626.24924.2.camel@wall-e>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andreas Schwab <schwab@linux-m68k.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Sorry, i missed this. Good job ;-)

Stefani

Am Samstag, den 03.10.2009, 08:47 +0200 schrieb Andreas Schwab:
> Here's the patch again properly signed.
> 
> Andreas.
> 
> >From 9da252fd7d9a5cf84a477a35a6b52f927c85b280 Mon Sep 17 00:00:00 2001
> From: Andreas Schwab <schwab@linux-m68k.org>
> Date: Sat, 3 Oct 2009 08:19:43 +0200
> Subject: [PATCH] compat_do_execve: set current->stack_start as in do_execve
> 
> Signed-off-by: Andreas Schwab <schwab@linux-m68k.org>
> ---
>  fs/compat.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/compat.c b/fs/compat.c
> index d576b55..6c19040 100644
> --- a/fs/compat.c
> +++ b/fs/compat.c
> @@ -1532,6 +1532,8 @@ int compat_do_execve(char * filename,
>  	if (retval < 0)
>  		goto out;
>  
> +	current->stack_start = current->mm->start_stack;
> +
>  	/* execve succeeded */
>  	current->fs->in_exec = 0;
>  	current->in_execve = 0;
> -- 
> 1.6.4.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
