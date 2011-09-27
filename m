Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6CFC49000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 13:05:29 -0400 (EDT)
Date: Tue, 27 Sep 2011 18:01:34 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: Question about memory leak detector giving false positive
 report for net/core/flow.c
Message-ID: <20110927170133.GN14237@e102109-lin.cambridge.arm.com>
References: <CA+v9cxadZzWr35Q9RFzVgk_NZsbZ8PkVLJNxjBAMpargW9Lm4Q@mail.gmail.com>
 <1317054774.6363.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110926165024.GA21617@e102109-lin.cambridge.arm.com>
 <1317066395.2796.11.camel@edumazet-laptop>
 <CA+v9cxYzWJScCa2mMoEovq3WULSZYQaq6EjoRV7SQUjr0L_RiQ@mail.gmail.com>
 <1317102918.2796.22.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317102918.2796.22.camel@edumazet-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Huajun Li <huajun.li.lee@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>

On Tue, Sep 27, 2011 at 06:55:18AM +0100, Eric Dumazet wrote:
> Yes, it was not a patch, but the general idea for Catalin ;)
> 
> You hit the fact that same zone (embedded percpu space) is now in a
> mixed state.
> 
> In current kernels, the embedded percpu zone is already known by
> kmemleak, but with a large granularity. kmemleak is not aware of
> individual allocations/freeing in this large zone.

It looks like this comes via the bootmem allocator. Maybe we could
simply call kmemleak_free() on the embedded percpu space and just track
those via the standard percpu API.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
