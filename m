Date: Sat, 23 Feb 2008 00:05:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 05/28] mm: allow PF_MEMALLOC from softirq context
Message-Id: <20080223000550.00cfbfa5.akpm@linux-foundation.org>
In-Reply-To: <20080220150305.905314000@chello.nl>
References: <20080220144610.548202000@chello.nl>
	<20080220150305.905314000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 15:46:15 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Allow PF_MEMALLOC to be set in softirq context. When running softirqs from
> a borrowed context save current->flags, ksoftirqd will have its own 
> task_struct.

The second sentence doesn't make sense.

> This is needed to allow network softirq packet processing to make use of
> PF_MEMALLOC.
>
> ...
>
> +#define tsk_restore_flags(p, pflags, mask) \
> +	do {	(p)->flags &= ~(mask); \
> +		(p)->flags |= ((pflags) & (mask)); } while (0)
> +

Does it need to be a macro?

If so, it really should cook up a temporary to avoid referencing p twice -
the children might be watching.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
