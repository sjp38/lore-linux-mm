Subject: Re: [patch00/05]: Containers(V2)- Introduction
From: Rohit Seth <rohitseth@google.com>
Reply-To: rohitseth@google.com
In-Reply-To: <451173B5.1000805@yahoo.com.au>
References: <1158718568.29000.44.camel@galaxy.corp.google.com>
	 <4510D3F4.1040009@yahoo.com.au> <1158751720.8970.67.camel@twins>
	 <4511626B.9000106@yahoo.com.au> <1158767787.3278.103.camel@taijtu>
	 <451173B5.1000805@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 20 Sep 2006 10:50:57 -0700
Message-Id: <1158774657.8574.65.camel@galaxy.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-09-21 at 03:00 +1000, Nick Piggin wrote:
> (this time to the lists as well)
> 
> Peter Zijlstra wrote:
> 
>  > I'd much rather containterize the whole reclaim code, which should not
>  > be too hard since he already adds a container pointer to struct page.
> 
> 

Right now the memory handler in this container subsystem is written in
such a way that when existing kernel reclaimer kicks in, it will first
operate on those (container with pages over the limit) pages first.  But
in general I like the notion of containerizing the whole reclaim code.

>  > I still have to reread what Rohit does for file backed pages, that gave
>  > my head a spin.

Please let me know if there is any specific part that isn't making much
sense.

-rohit


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
