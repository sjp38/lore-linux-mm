Date: Tue, 10 Feb 2004 13:05:59 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.3-rc1-mm1
Message-Id: <20040210130559.22b24092.akpm@osdl.org>
In-Reply-To: <200402101345.19015.iggy@gentoo.org>
References: <20040209014035.251b26d1.akpm@osdl.org>
	<200402101345.19015.iggy@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brian Jackson <iggy@gentoo.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Brian Jackson <iggy@gentoo.org> wrote:
>
> kernel bug at mm/slab.c:1107!
> invalid operand:0000 [#1]
> SMP
> 
> (this happened just after the Console: and Memory: lines)
> This didn't happen with 2.6.1-mm4 (that's the last -mm I tried). I can try to 
> track down where it started later, but this is my firewall, so I have to wait 
> till everyone goes to sleep first.

Yes, I know.  Seems that with some configs, each interrupt (only timer
interrupts at this point) is decrementing the preempt count by one.  It's
rather mysterious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
