Received: from m4.gw.fujitsu.co.jp ([10.0.50.74]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7R0atwH008075 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 09:36:55 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7R0atTM020151 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 09:36:55 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail502.fjmail.jp.fujitsu.com (fjmail502-0.fjmail.jp.fujitsu.com [10.59.80.98]) by s6.gw.fujitsu.co.jp (8.12.11)
	id i7R0asIE015326 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 09:36:54 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail502.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I320066LXPHFK@fjmail502.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri, 27 Aug 2004 09:36:54 +0900 (JST)
Date: Fri, 27 Aug 2004 09:42:05 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC] buddy allocator without bitmap [3/4]
In-reply-to: <1093565707.2984.394.camel@nighthawk>
Message-id: <412E835D.8080500@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <412DD34A.70802@jp.fujitsu.com>
 <1093535709.2984.24.camel@nighthawk> <412E7AB6.8020707@jp.fujitsu.com>
 <1093565707.2984.394.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
>>1. Now, I think some small parts, some essence of mem_section which
>>   makes pfn_valid() faster may be good.
> 
> 
> The only question is what it will take when there's a partially populate
> mem_section.  We'll almost certainly have to allow it, but the real
> question is whether or not we will ever have a partially populated one
> that's not at the end of memory.  
> 
Hmm....I cannot answer it fully.

My tiger4 (Itanium x 2) shows aligned_order=0, because it has a mem_map
start with address 0x????????3(I forget now), odd number ;(.
I like a mechine in which all memory are aligned.....

>>And another way,
>>
>>2. A method which enables page -> page's max_order calculation
>>   may be good and consistent way in this no-bitmap approach.
>>
>>But this problem would be my week-end homework :).
> 
> 
> Instead of adding more stuff to the mem_section, we might be able to
> (ab)use more stuff in the mem_map's mem_map, like I am with
> page->section right now.  

I wonder if there is another way which doesn't increase memory usage
in boottime, it will be better.
I'll going on considering the way to fix nr_mem_map things.

Thanks
-- Kame


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
