Subject: Re: [Lhms-devel] Re: [RFC] buddy allocator without bitmap [3/4]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <412E7AB6.8020707@jp.fujitsu.com>
References: <412DD34A.70802@jp.fujitsu.com>
	 <1093535709.2984.24.camel@nighthawk>  <412E7AB6.8020707@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093565707.2984.394.camel@nighthawk>
Mime-Version: 1.0
Date: Thu, 26 Aug 2004 17:15:08 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-08-26 at 17:05, Hiroyuki KAMEZAWA wrote:
> Currently, I think zone->nr_mem_map itself is very vague.
> I'm now looking for another way to remove this part entirely.
> 
> I think mem_section approarch may be helpful to remove this part,
> but to implement full feature of CONFIG_NONLINEAR,
> I'll need lots of different kind of patches.
> (If mem_map is guaranteed to be contiguous in one mem_section)

This is definitely a true assumption right now.  

> 1. Now, I think some small parts, some essence of mem_section which
>    makes pfn_valid() faster may be good.

The only question is what it will take when there's a partially populate
mem_section.  We'll almost certainly have to allow it, but the real
question is whether or not we will ever have a partially populated one
that's not at the end of memory.  

> And another way,
> 
> 2. A method which enables page -> page's max_order calculation
>    may be good and consistent way in this no-bitmap approach.
> 
> But this problem would be my week-end homework :).

Instead of adding more stuff to the mem_section, we might be able to
(ab)use more stuff in the mem_map's mem_map, like I am with
page->section right now.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
