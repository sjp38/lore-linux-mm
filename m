Message-ID: <3E4978B6.9030201@us.ibm.com>
Date: Tue, 11 Feb 2003 14:27:02 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
MIME-Version: 1.0
Subject: Re: [Lse-tech] [rfc][api] Shared Memory Binding
References: <DD755978BA8283409FB0087C39132BD1A07CD2@fmsmsx404.fm.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech@lists.sourceforge.net, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Luck, Tony wrote:
>>	I've got a pseudo manpage for a new call I'm attempting 
>>to implement: 
>>shmbind().  The idea of the call is to allow userspace 
>>processes to bind 
>>shared memory segments to particular nodes' memory and do so 
>>according 
>>to certain policies.  Processes would call shmget() as usual, 
>>but before 
>>calling shmat(), the process could call shmbind() to set up a binding 
>>for the segment.  Then, any time pages from the shared segment are 
>>faulted into memory, it would be done according to this binding.
>>	Any comments about the attatched manpage, the idea in 
>>general, how to improve it, etc. are definitely welcome.
> 
> 
> Why tie this to the sysV ipc shm mechanism?  Couldn't you make
> a more general "mmbind()" call that applies to a "start, len"
> range of virtual addresses?  This would work for your current
> usage (but you would apply it after the "shmat()"), but it would
> also be useful for memory allocated to a process with mmap(), sbrk()
> and even general .text/.data if you managed to call it before you
> touched pages.
> 
> -Tony

I'd hoped to see how this proposal and pending patch went over with 
everyone, before attempting anything more broad.  My last attempt at 
something similar to this failed due to being too invasive and 
complicated.  My thoughts were to try something fairly straightforward 
and simple this time.  The patch I'm working on to implement this could 
however lead to something like what you described if desired.  I'm 
trying to allow for the possibility of expanding the power of bindings 
with my code.  And I also think that these types of bindings could be 
useful in a more general way.

Cheers!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
