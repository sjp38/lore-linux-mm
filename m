Date: Fri, 22 Feb 2008 15:59:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Document huge memory/cache overhead of memory
 controller in Kconfig
Message-Id: <20080222155916.9cc4ca6e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47BD5A85.5010401@linux.vnet.ibm.com>
References: <20080220122338.GA4352@basil.nowhere.org>
	<47BC2275.4060900@linux.vnet.ibm.com>
	<200802211535.38932.nickpiggin@yahoo.com.au>
	<47BD546B.1050504@firstfloor.org>
	<47BD5A85.5010401@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Feb 2008 16:33:33 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > Another issue is that it will slightly increase TLB/cache
> > cost of the memory controller, but I think that would be a fair
> > trade off for it being zero cost when disabled but compiled
> > in.
> > 
> > Doing it with vmalloc should be easy enough. I can do such
> > a patch later unless someone beats me to it...
> > 
> 
> I'll get to it, but I have too many things on my plate at the moment. KAMEZAWA
> also wanted to look at it. I looked through some vmalloc() internals yesterday
> and I am worried about allocating all the memory on a single node in a NUMA
> system and changing VMALLOC_XXXX on every architecture to provide more vmalloc
> space. I might be missing something obvious.
> 

I'll post a series of patch to do that later (it's under debug now...)
I'm glad if people (including you) look it and give me advices.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
