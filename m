Date: Wed, 12 Sep 2007 05:44:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 11 of 24] the oom schedule timeout isn't needed with the
 VM_is_OOM logic
Message-Id: <20070912054416.7b16bfcd.akpm@linux-foundation.org>
In-Reply-To: <adf88d0ba0d17beaceee.1187786938@v2.random>
References: <patchbomb.1187786927@v2.random>
	<adf88d0ba0d17beaceee.1187786938@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 14:48:58 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@suse.de>
> # Date 1187778125 -7200
> # Node ID adf88d0ba0d17beaceee47f7b8e0acbd97ddc320
> # Parent  edb3af3e0d4f2c083c8ddd9857073a3c8393ab8e
> the oom schedule timeout isn't needed with the VM_is_OOM logic
> 
> VM_is_OOM whole point is to give a proper time to the TIF_MEMDIE task
> in order to exit.
> 
> Signed-off-by: Andrea Arcangeli <andrea@suse.de>
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -469,12 +469,5 @@ out:

It's a shame that mercurial has inherited `diff -p's stupid handling of labels.
I guess it uses diff directly.  ho hum.

>  	read_unlock(&tasklist_lock);
>  	cpuset_unlock();
>  
> -	/*
> -	 * Give "p" a good chance of killing itself before we
> -	 * retry to allocate memory unless "p" is current
> -	 */
> -	if (!test_thread_flag(TIF_MEMDIE))
> -		schedule_timeout_uninterruptible(1);
> -
>  	up(&OOM_lock);
>  }
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
