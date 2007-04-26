Date: Thu, 26 Apr 2007 19:10:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] change global zonelist order on NUMA v2
Message-Id: <20070426191043.df96c114.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200704261147.44413.ak@suse.de>
References: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com>
	<200704261147.44413.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 26 Apr 2007 11:47:44 +0200
Andi Kleen <ak@suse.de> wrote:

> On Thursday 26 April 2007 11:34:17 KAMEZAWA Hiroyuki wrote:
> > 
> > Changelog from V1 -> V2
> > - sysctl name is changed to be relaxed_zone_order
> > - NORMAL->NORMAL->....->DMA->DMA->DMA order (new ordering) is now default.
> >   NORMAL->DMA->NORMAL->DMA order (old ordering) is optional.
> > - addes boot opttion to set relaxed_zone_order. ia64 is supported now.
> > - Added documentation
> > 
> > patch is against 2.6.21-rc7-mm2. tested on ia64 NUMA box. works well.
> 
> IMHO the change should be default (without any options) unless someone
> can come up with a good reason why not. On x86-64 it should be definitely
> default.
> 
> If there is a good reason on some architecture or machine a user option is also not a 
> good idea, but instead it should be set automatically by that architecture or machine
> on boot.
> 
Hmm...sounds reasonable. 

I have 2 idea for automatic way..

(1)Use new zonelist ordering always and move init_task's tied cpu to a
  cpu on the best node. 
  Child processes will start in good nodes even if Node 0 has small memory.

(2) Set Node's local highest zone to the top of zonelist.

I like (1). Does anyone have an idea ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
