Message-ID: <413F6362.6000001@sgi.com>
Date: Wed, 08 Sep 2004 14:54:10 -0500
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
References: <413CB661.6030303@sgi.com> <cone.1094512172.450816.6110.502@pc.kolivas.org> <20040906162740.54a5d6c9.akpm@osdl.org> <cone.1094513660.210107.6110.502@pc.kolivas.org> <20040907000304.GA8083@logos.cnet> <20040907212051.GC3492@logos.cnet> <413F1518.7050608@sgi.com> <5860000.1094664673@flay>
In-Reply-To: <5860000.1094664673@flay>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>


Martin J. Bligh wrote:
>>It seems to me that the 5% number in there is more or less arbitrary. 
>>If we are on a big memory Altix (4 TB), 5% of memory would be 200 GB. 
>>That is a lot of page cache.
> 
> 
> For HPC, maybe. For a fileserver, it might be far too little. That's the
> trouble ... it's all dependant on the workload. Personally, I'd prefer
> to get rid of manual tweakables (which are a pain in the ass in the field
> anyway), and try to have the kernel react to what the customer is doing.
> I guess we can leave them there for overrides, but a self-tunable default
> would be most desirable.
> 

I agree that tunables are a pain in the butt, but a quick fix would to be at 
least to add that 5% to the set of stuff settable in /proc/sys/vm.  Most
workloads/systems won't need to change it.  Very large Altix systems could 
change it if needed.

I don't think that is at the root of the swappiness problems with 
2.6.9-rc1-mm3, though.

> For instance, would be nice if we started doing writeback to the spindles
> that weren't busy much earlier than if the disks were thrashing.
> 
> M.
> 
> 

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
