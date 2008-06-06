Message-ID: <4849AC21.5090301@brontes3d.com>
Date: Fri, 06 Jun 2008 22:29:05 +0100
From: Daniel Drake <ddrake@brontes3d.com>
MIME-Version: 1.0
Subject: Re: faulting kmalloced buffers into userspace through mmap()
References: <4842B4C3.1070506@brontes3d.com> <87mym4tmz0.fsf@saeurebad.de> <484662E3.40902@brontes3d.com> <200806042100.39345.nickpiggin@yahoo.com.au>
In-Reply-To: <200806042100.39345.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Johannes Weiner <hannes@saeurebad.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> You can map it with a pfn mapping / vm_insert_pfn / remap_pfn_range etc.
> which does not touch the underlying struct pages. You must then ensure
> you deallocate the memory yourself after it is finished with.

Ah, excellent, I wasn't aware of pfn mappings or vm_insert_pfn. I should 
have read further than LDD3 :)

I have brushed up the section I wrote earlier:
http://linux-mm.org/DeviceDriverMmap

Hopefully someone else will find it useful.

Since I'm working with 2.6.25 I've implemented a nopfn handler which 
works perfectly using vm_insert_pfn(). Thanks for all your great work in 
this area!
-- 
Daniel Drake
Brontes Technologies, A 3M Company
http://www.brontes3d.com/opensource/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
