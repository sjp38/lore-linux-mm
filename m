Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9JJCUPg002814
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 15:12:30 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9JJDK6k543630
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 13:13:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9JJCQf5028591
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 13:12:26 -0600
Message-ID: <43569A8F.4040300@us.ibm.com>
Date: Wed, 19 Oct 2005 12:12:15 -0700
From: Darren Hart <dvhltc@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
References: <1129570219.23632.34.camel@localhost.localdomain>	 <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com>	 <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com>	 <1129651502.23632.63.camel@localhost.localdomain>	 <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com> <1129747855.8716.12.camel@localhost.localdomain>
In-Reply-To: <1129747855.8716.12.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Chris Wright <chrisw@osdl.org>, Jeff Dike <jdike@addtoit.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote:
>> ...
>>I say "as far as it goes" because I don't think it's actually going to
>>achieve the effect you said you wanted in your original post.
>>
>>As you've probably noticed, switching off VM_ACCOUNT here will mean that
>>the shm object is accounted page by page as it's instantiated, and I
>>expect you're okay with that.  But you want madvise(DONTNEED) to free
>>up those reservations: it'll unmap the pages from userspace, but it
>>won't free the pages from the shm object, so the reservations will
>>still be in force, and accumulate.
> 
> 
> Darren Hart is working on patch to add madvise(DISCARD) to extend
> the functionality of madvise(DONTNEED) to really drop those pages.
> I was going to ask your opinion on that approach :) 
> 
> shmget(SHM_NORESERVE) + madvise(DISCARD) should do what I was
> hoping for. (BTW, none of this has been tested with database stuff -
> I am just concentrating on reasonable extensions.
> 
> Here is the version of patch under test. 
> (Darren - I am sending this out without your permission, I hope
> you are okay with it).
>  

Of course, no problem.  I have a separate patch for sles9sp2 if that is of 
interest.  Please keep me in the loop with any feedback on the patch.

-- 
Darren Hart
IBM Linux Technology Center
Linux Kernel Team
Phone: 503 578 3185
   T/L: 775 3185

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
