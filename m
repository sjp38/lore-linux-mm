Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D7F839000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 14:30:50 -0400 (EDT)
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.DEB.2.00.1107071314320.21719@router.home>
References: <20110626193918.GA3339@joi.lan>
	 <alpine.DEB.2.00.1107072106560.6693@tiger>
	 <alpine.DEB.2.00.1107071314320.21719@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 07 Jul 2011 13:30:44 -0500
Message-ID: <1310063444.3637.10.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Marcin Slusarz <marcin.slusarz@gmail.com>, LKML <linux-kernel@vger.kernel.org>, rientjes@google.com, linux-mm@kvack.org

On Thu, 2011-07-07 at 13:17 -0500, Christoph Lameter wrote:
> On Thu, 7 Jul 2011, Pekka Enberg wrote:
> 
> > Looks good to me. Christoph, David, ?
> 
> The reason debug code is there is because it is useless overhead typically
> not needed. There is no point in optimizing the code that is not run in
> production environments unless there are gross performance issues that
> make debugging difficult. A performance patch for debugging would have to
> cause significant performance improvements. This patch does not do that
> nor was there such an issue to be addressed in the first place.

Deja vu.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
