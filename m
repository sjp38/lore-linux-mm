Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B9D4F9000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 14:52:54 -0400 (EDT)
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <alpine.DEB.2.00.1107071314320.21719@router.home>
References: <20110626193918.GA3339@joi.lan>
	 <alpine.DEB.2.00.1107072106560.6693@tiger>
	 <alpine.DEB.2.00.1107071314320.21719@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 07 Jul 2011 21:52:51 +0300
Message-ID: <1310064771.21902.55.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Marcin Slusarz <marcin.slusarz@gmail.com>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, rientjes@google.com, linux-mm@kvack.org

On Thu, 7 Jul 2011, Pekka Enberg wrote:
> > Looks good to me. Christoph, David, ?

On Thu, 2011-07-07 at 13:17 -0500, Christoph Lameter wrote:
> The reason debug code is there is because it is useless overhead typically
> not needed. There is no point in optimizing the code that is not run in
> production environments unless there are gross performance issues that
> make debugging difficult. A performance patch for debugging would have to
> cause significant performance improvements. This patch does not do that
> nor was there such an issue to be addressed in the first place.

Is there something technically wrong with the patch? Quoting the patch
email:

  (Compiling some project with different options)
                                 make -j12    make clean
  slub_debug disabled:             1m 27s       1.2 s
  slub_debug enabled:              1m 46s       7.6 s
  slub_debug enabled + this patch: 1m 33s       3.2 s

  check_bytes still shows up high, but not always at the top.

That's significant enough speedup for me!

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
