Date: Wed, 26 Jan 2005 19:40:02 -0800
Message-Id: <200501270340.j0R3e2KX011157@magilla.sf.frob.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: [patch] ptrace: unlocked access to last_siginfo (resending)
In-Reply-To: Prasanna Meda's message of  Wednesday, 26 January 2005 19:36:05 -0800 <41F861A5.1C21FE1@akamai.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Prasanna Meda <pmeda@akamai.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>   Thanks, but looks like we fixed only part of the problem. If the
>   child is on the exit path and releases sighand, we need to check for
>   its existence too.  The attached patch should work.

That's correct.  Technically you don't need read_lock_irq, but just
spin_lock_irq, not that it really makes a difference.  Myself, I would
change that and also use struct assignment instead of memcpy.
But your patch is fine as it is.


Thanks,
Roland
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
