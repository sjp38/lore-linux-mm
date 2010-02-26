Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 98D436B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 05:45:07 -0500 (EST)
Message-ID: <4B87A62E.5030307@cs.helsinki.fi>
Date: Fri, 26 Feb 2010 12:45:02 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
References: <20100211953.850854588@firstfloor.org> <20100211205404.085FEB1978@basil.firstfloor.org> <20100215061535.GI5723@laptop> <20100215103250.GD21783@one.firstfloor.org> <20100215104135.GM5723@laptop> <20100215105253.GE21783@one.firstfloor.org> <20100215110135.GN5723@laptop> <alpine.DEB.2.00.1002191222320.26567@router.home> <20100220090154.GB11287@basil.fritz.box> <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi> <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <alpine.DEB.2.00.1002251315010.3501@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251627040.18861@router.home>
In-Reply-To: <alpine.DEB.2.00.1002251627040.18861@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter kirjoitti:
>> kmalloc_node() in generic kernel code.  All that is done under
>> MEM_GOING_ONLINE and not MEM_ONLINE, which is why I suggest the first and
>> fourth patch in this series may not be necessary if we prevent setting the
>> bit in the nodemask or building the zonelists until the slab nodelists are
>> ready.
> 
> That sounds good.

Andi?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
