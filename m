Message-ID: <3D9874E7.70805@colorfullife.com>
Date: Mon, 30 Sep 2002 17:59:35 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATH] slab cleanup
References: <3D96F559.2070502@colorfullife.com> <732392454.1033343702@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: lse-tech@lists.sourceforge.net, akpm@digeo.com, tomlins@cam.org, "Kamble, Nitin A" <nitin.a.kamble@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
>>Could someone test that it works on real SMP?
> 
> 
> Tested on 16-way NUMA-Q (shows up races quicker than anything ;-)). 
> Boots, compiles the kernel 5 times OK. That's good enough for me. 
> No performance regression, in fact was marginally faster (within 
> experimental error though).
> 
Thanks for the test. NUMA is on my TODO list, after figuring out 
where/how to drain cpu caches and the free list.

I've found one stupid bug with debugging enabled: the new debug code 
tries to poison NULL pointers, with limited success :-(

And one limitation might be important for arch specific code: 
kmem_cache_create() during mem_init() is not possible anymore.

--
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
