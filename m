Message-ID: <43CD822C.6020105@jp.fujitsu.com>
Date: Wed, 18 Jan 2006 08:47:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Question:  new bind_zonelist uses only one zone type
References: <43CCAEEF.5000403@jp.fujitsu.com> <200601171529.53811.ak@suse.de>
In-Reply-To: <200601171529.53811.ak@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> It was originally intended - back then either IA64 NUMA systems didn't
> have a ZONE_DMA and on x86-64 it was only 16MB and for i386 NUMA
> it was considered acceptable - and it made the  code simpler and policies 
> use less memory. But is now considered a bug because of the introduction 
> of ZONE_DMA32 on x86-64 and I gather from your report your platform
> has NUMA and a 4GB ZONE_DMA too?
> 
on ia64, 0-4G area is ZONE_DMA.


> It is on my todo list to fix, but I haven't gotten around to it yet. 
> 
> Fixing it will unfortunately increase the footprint of the policy structures, 
> so likely it would only increase to two. If someone beats me to a patch
> that would be ok too.
> 
I don't have real problem now. It just looks curious.
And, anyway, mbind's list doesn't guarantee fair allocation among nodes.

Thanks,
-- Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
