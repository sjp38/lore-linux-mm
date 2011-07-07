Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C6D2F9000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 14:30:32 -0400 (EDT)
Message-ID: <4E15FB3E.9050108@candelatech.com>
Date: Thu, 07 Jul 2011 11:30:22 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
References: <20110626193918.GA3339@joi.lan> <alpine.DEB.2.00.1107072106560.6693@tiger> <alpine.DEB.2.00.1107071314320.21719@router.home>
In-Reply-To: <alpine.DEB.2.00.1107071314320.21719@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Marcin Slusarz <marcin.slusarz@gmail.com>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, rientjes@google.com, linux-mm@kvack.org

On 07/07/2011 11:17 AM, Christoph Lameter wrote:
> On Thu, 7 Jul 2011, Pekka Enberg wrote:
>
>> Looks good to me. Christoph, David, ?
>
> The reason debug code is there is because it is useless overhead typically
> not needed. There is no point in optimizing the code that is not run in
> production environments unless there are gross performance issues that
> make debugging difficult. A performance patch for debugging would have to
> cause significant performance improvements. This patch does not do that
> nor was there such an issue to be addressed in the first place.

The more painful you make it, the less likely folks are to use it
in environments that actually reproduce bugs, so I think it's quite
short-sighted to reject such performance improvements out of hand.

And what if some production machine has funny crashes in a specific
work-load....wouldn't it be nice if it could enable debugging and
still perform well enough to do it's job?

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
