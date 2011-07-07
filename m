Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 98C219000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 14:54:18 -0400 (EDT)
Message-ID: <4E1600D3.8050105@candelatech.com>
Date: Thu, 07 Jul 2011 11:54:11 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
References: <20110626193918.GA3339@joi.lan> <alpine.DEB.2.00.1107072106560.6693@tiger> <alpine.DEB.2.00.1107071314320.21719@router.home> <4E15FB3E.9050108@candelatech.com> <alpine.DEB.2.00.1107071341120.21719@router.home>
In-Reply-To: <alpine.DEB.2.00.1107071341120.21719@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Marcin Slusarz <marcin.slusarz@gmail.com>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, rientjes@google.com, linux-mm@kvack.org

On 07/07/2011 11:42 AM, Christoph Lameter wrote:
> On Thu, 7 Jul 2011, Ben Greear wrote:
>
>> The more painful you make it, the less likely folks are to use it
>> in environments that actually reproduce bugs, so I think it's quite
>> short-sighted to reject such performance improvements out of hand.
>>
>> And what if some production machine has funny crashes in a specific
>> work-load....wouldn't it be nice if it could enable debugging and
>> still perform well enough to do it's job?
>
> Sure if there would be significant improvements that accomplish what
> you claim above then that would be certainly worthwhile. Come up with
> patches like that please.

The patch appears to make some work loads twice as fast ('make clean'),
and it had a reasonable speedup to the 'make -j12'.  What do you
consider 'significant'?

I'm willing to do some other network-related benchmarks with his patch if
that would give it better chance of being accepted.  (I end up running
with SLUB debug quite a bit on big, heavy, workloads...so any speedup
in that would be a big help for us...)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
