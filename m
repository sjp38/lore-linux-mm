Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1539E9000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 14:43:00 -0400 (EDT)
Date: Thu, 7 Jul 2011 13:42:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
In-Reply-To: <4E15FB3E.9050108@candelatech.com>
Message-ID: <alpine.DEB.2.00.1107071341120.21719@router.home>
References: <20110626193918.GA3339@joi.lan> <alpine.DEB.2.00.1107072106560.6693@tiger> <alpine.DEB.2.00.1107071314320.21719@router.home> <4E15FB3E.9050108@candelatech.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Greear <greearb@candelatech.com>
Cc: Pekka Enberg <penberg@kernel.org>, Marcin Slusarz <marcin.slusarz@gmail.com>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, rientjes@google.com, linux-mm@kvack.org

On Thu, 7 Jul 2011, Ben Greear wrote:

> The more painful you make it, the less likely folks are to use it
> in environments that actually reproduce bugs, so I think it's quite
> short-sighted to reject such performance improvements out of hand.
>
> And what if some production machine has funny crashes in a specific
> work-load....wouldn't it be nice if it could enable debugging and
> still perform well enough to do it's job?

Sure if there would be significant improvements that accomplish what
you claim above then that would be certainly worthwhile. Come up with
patches like that please.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
