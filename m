Message-ID: <4292202D.5020905@rentec.com>
Date: Mon, 23 May 2005 14:25:49 -0400
From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Avoiding mmap fragmentation - clean rev
References: <200505202351.j4KNpHg21468@unix-os.sc.intel.com>
In-Reply-To: <200505202351.j4KNpHg21468@unix-os.sc.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, herve@elma.fr, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W wrote:
> Andrew Morton wrote on Thursday, May 19, 2005 3:55 PM
> 
>>Wolfgang Wander <wwc@rentec.com> wrote:
>>
>>>Clearly one has to weight the performance issues against the memory
>>> efficiency but since we demonstratibly throw away 25% (or 1GB) of the
>>> available address space in the various accumulated holes a long
>>> running application can generate
>>
>>That sounds pretty bad.
>>
>>
>>>I hope that for the time being we can
>>> stick with my first solution,
>>
>>I'm inclined to do this.
>>
>>
>>>preferably extended by your munmap fix?
>>
>>And this, if someone has a patch? 
> 
> 
> 
> 2nd patch on top of wolfgang's patch.  It's a compliment on top of initial
> attempt by wolfgang to solve the fragmentation problem.  The code path
> in munmap is suboptimal and potentially worsen the fragmentation because
> with a series of munmap, the free_area_cache would point to last vma that
> was freed, ignoring its surrounding and not performing any coalescing at all,
> thus artificially create more holes in the virtual address space than necessary.
> Since all the information needed to perform coalescing are actually already there.
> This patch put that data in use so we will prevent artificial fragmentation.
> 
> It covers both bottom-up and top-down topology.  For bottom-up topology,
> free_area_cache points to prev->vm_end. And for top-down, free_area_cache points
> to next->vm_start.


Works perfectly fine here.  All my tests pass and our large applications 
are happy with this patch.

Thanks Ken for your patience with my lack of it ;-)

             Wolfgang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
