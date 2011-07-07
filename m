Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 728849000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 14:17:53 -0400 (EDT)
Date: Thu, 7 Jul 2011 13:17:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
In-Reply-To: <alpine.DEB.2.00.1107072106560.6693@tiger>
Message-ID: <alpine.DEB.2.00.1107071314320.21719@router.home>
References: <20110626193918.GA3339@joi.lan> <alpine.DEB.2.00.1107072106560.6693@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Marcin Slusarz <marcin.slusarz@gmail.com>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, rientjes@google.com, linux-mm@kvack.org

On Thu, 7 Jul 2011, Pekka Enberg wrote:

> Looks good to me. Christoph, David, ?

The reason debug code is there is because it is useless overhead typically
not needed. There is no point in optimizing the code that is not run in
production environments unless there are gross performance issues that
make debugging difficult. A performance patch for debugging would have to
cause significant performance improvements. This patch does not do that
nor was there such an issue to be addressed in the first place.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
