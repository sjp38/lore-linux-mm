Message-ID: <4005FD76.4030800@cyberone.com.au>
Date: Thu, 15 Jan 2004 13:39:50 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.1-mm3
References: <20040114014846.78e1a31b.akpm@osdl.org>
In-Reply-To: <20040114014846.78e1a31b.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6.1-mm3/
>
>
>- A big ppc64 update from Anton
>
>- Added Nick's CPU scheduler patches for hyperthreaded/SMT CPUs.  This work
>  needs lots of testing and review from those who care about and work upon
>  this feature, please.
>

This also includes my SMP / NUMA scheduler work, so it should help
larger SMP and especially NUMA systems. Testing would be good.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
