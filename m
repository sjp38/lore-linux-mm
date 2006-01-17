From: Andi Kleen <ak@suse.de>
Subject: Re: Question:  new bind_zonelist uses only one zone type
Date: Tue, 17 Jan 2006 15:29:53 +0100
References: <43CCAEEF.5000403@jp.fujitsu.com>
In-Reply-To: <43CCAEEF.5000403@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200601171529.53811.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 17 January 2006 09:46, KAMEZAWA Hiroyuki wrote:

> policy_zone is ZONE_DMA, ZONE_NORMAL, ZONE_HIGHMEM, depends on system.
> 
> If policy_zone is ZONE_NORMAL, returned zonelist will be
> {Node(0)'s NORMAL, Node(1)'s NORMAL, Node(2)'s Normal.....}
> 
> If node0 has only DMA/DMA32 and Node1-NodeX has Normal, node0 will be ignored
> and zonelist will include not-populated zone.
> 
> Is this intended ?

I was wondering when someone else would notice. Congratulations, you 
are the first ;-)

It was originally intended - back then either IA64 NUMA systems didn't
have a ZONE_DMA and on x86-64 it was only 16MB and for i386 NUMA
it was considered acceptable - and it made the  code simpler and policies 
use less memory. But is now considered a bug because of the introduction 
of ZONE_DMA32 on x86-64 and I gather from your report your platform
has NUMA and a 4GB ZONE_DMA too?

It is on my todo list to fix, but I haven't gotten around to it yet. 

Fixing it will unfortunately increase the footprint of the policy structures, 
so likely it would only increase to two. If someone beats me to a patch
that would be ok too.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
