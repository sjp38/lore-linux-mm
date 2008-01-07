Date: Mon, 7 Jan 2008 11:43:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 11 of 11] not-wait-memdie
In-Reply-To: <504e981185254a12282d.1199326157@v2.random>
Message-ID: <Pine.LNX.4.64.0801071141130.23617@schroedinger.engr.sgi.com>
References: <504e981185254a12282d.1199326157@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jan 2008, Andrea Arcangeli wrote:

> +		if (unlikely(test_tsk_thread_flag(p, TIF_MEMDIE))) {
> +			/*
> +			 * Hopefully we already waited long enough,
> +			 * or exit_mm already run, but we must try to kill
> +			 * another task to avoid deadlocking.
> +			 */
> +			continue;
> +		}

If all tasks are marked TIF_MEMDIE then we just scan through them return 
NULL and


>  		/* Found nothing?!?! Either we hang forever, or we panic. */
> -		if (!p) {
> +		if (unlikely(!p)) {
>  			read_unlock(&tasklist_lock);
>  			panic("Out of memory and no killable processes...\n");

panic.

Should we not wait awhile before panicing? The processes may need some 
time to terminate.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
