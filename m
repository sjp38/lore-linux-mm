Date: Thu, 13 Jan 2005 23:46:31 -0800
Message-Id: <200501140746.j0E7kVf3008191@magilla.sf.frob.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: [patch] ptrace: unlocked access to last_siginfo (resending)
In-Reply-To: pmeda@akamai.com's message of  Tuesday, 11 January 2005 19:11:50 -0800 <200501120311.TAA01315@allur.sanmateo.akamai.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pmeda@akamai.com
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Since Roland changed now to wakeup tracee with kill, I guess this needs to be fixed.
> http://linus.bkbits.net:8080/linux-2.5/gnupatch@41e3fe5fIRH-W3aDnXZgfQ-qIvuXYg
Indeed, this change should go in.  I'd forgotten about this.  I don't think
there are any other things we decided to leave one way or another based on
the ptrace behavior that has now changed back again, but I might be
forgetting others too.  Thanks for bringing it up.


Thanks,
Roland
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
