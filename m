Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A9E3B8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 19:15:08 -0500 (EST)
Message-ID: <4D420A89.3050906@linux.intel.com>
Date: Thu, 27 Jan 2011 16:15:05 -0800
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: Make vm_acct_memory scalable for large memory allocations
References: <1296082319.2712.100.camel@schen9-DESK> <20110127153642.f022b51c.akpm@linux-foundation.org>
In-Reply-To: <20110127153642.f022b51c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


> This seems like a pretty dumb test case.  We have 64 cores sitting in a
> loop "allocating" 32MB of memory, not actually using that memory and
> then freeing it up again.
>
> Any not-completely-insane application would actually _use_ the memory.
> Which involves pagefaults, page allocations and much memory traffic
> modifying the page contents.
>
> Do we actually care?

It's a bit like a poorly tuned malloc. From what I heard poorly tuned 
mallocs are quite
common in the field, also with lots of custom ones around.

While it would be good to tune them better the kernel should also have 
reasonable performance
for this case.

The poorly tuned malloc has other problems too, but this addresses at 
least one
of them.

Also I think Tim's patch is a general improvement to a somewhat dumb 
code path.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
