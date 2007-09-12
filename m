Date: Wed, 12 Sep 2007 06:02:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 19 of 24] cacheline align VM_is_OOM to prevent false
 sharing
Message-Id: <20070912060255.c5b95414.akpm@linux-foundation.org>
In-Reply-To: <be2fc447cec06990a2a3.1187786946@v2.random>
References: <patchbomb.1187786927@v2.random>
	<be2fc447cec06990a2a3.1187786946@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 14:49:06 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@suse.de>
> # Date 1187778125 -7200
> # Node ID be2fc447cec06990a2a31658b166f0c909777260
> # Parent  040cab5c8aafe1efcb6fc21d1f268c11202dac02
> cacheline align VM_is_OOM to prevent false sharing
> 
> This is better to be cacheline aligned in smp kernels just in case.
> 
> Signed-off-by: Andrea Arcangeli <andrea@suse.de>
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -29,7 +29,7 @@ int sysctl_panic_on_oom;
>  int sysctl_panic_on_oom;
>  /* #define DEBUG */
>  
> -unsigned long VM_is_OOM;
> +unsigned long VM_is_OOM __cacheline_aligned_in_smp;
>  static unsigned long last_tif_memdie_jiffies;
>  

I'd suggest __read_mostly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
