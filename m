Date: Tue, 31 Jul 2007 06:35:29 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: [SPARC32] NULL pointer derefference
In-Reply-To: <20070729.211929.78713482.davem@davemloft.net>
Message-ID: <Pine.LNX.4.61.0707310557470.3926@mtfhpc.demon.co.uk>
References: <Pine.LNX.4.61.0707300301340.32210@mtfhpc.demon.co.uk>
 <20070729.211929.78713482.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: aaw@google.com, akpm@linux-foundation.org, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, wli@holomorphy.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi David,

>
> One possible issue is sequencing, perhaps the stack argument copy
> is occuring before the new context is setup properly on sun4c.
>

I think it is somthing related to this but too much has changed for me to 
work out what is going on. At present, I don't have a good enough 
understanding of the virtual memory system and how it interracts with the 
sun4c mmu.

The original code did a job lot of pte stuf in install_arg_page. The new 
code seems to replace this using get_user_pages but I have not worked out 
how get_user_pages gets to the point at which it allocated pte's i.e. 
maps the stack memory it is about to put the arguments into.

> Another issue might be the new flush_cache_page() call in this
> new code in fs/exec.c, there are now cases where flush_cache_page()
> will be called on kernel addresses, and sun4c's implementation might
> not like that at all.

I commented out the flush_cache_page callmade in the new code. This had no 
effect on the problem. Other tests have shown it is breaking earlier than 
this.

I am going to try to narrow down exactly where the pointer gets messed up 
as this should help.

Regards
 	Mark Fortescue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
