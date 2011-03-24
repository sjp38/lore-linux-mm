Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 143AD8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:29:08 -0400 (EDT)
Received: by yws5 with SMTP id 5so182250yws.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 12:29:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110324192712.GA7156@elte.hu>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
	<20110324142146.GA11682@elte.hu>
	<alpine.DEB.2.00.1103240940570.32226@router.home>
	<AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
	<20110324172653.GA28507@elte.hu>
	<alpine.DEB.2.00.1103242011540.4990@tiger>
	<20110324192712.GA7156@elte.hu>
Date: Thu, 24 Mar 2011 21:29:06 +0200
Message-ID: <AANLkTi=YRYpBmni4CBmiOXML=w4CVH+AveAwLu=tt_rB@mail.gmail.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Lameter <cl@linux.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 24, 2011 at 9:27 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Pekka Enberg <penberg@kernel.org> wrote:
>
>> >From dd1534455196d2a8f6c9c912db614e59986c9f0e Mon Sep 17 00:00:00 2001
>> From: Pekka Enberg <penberg@kernel.org>
>> Date: Thu, 24 Mar 2011 19:59:35 +0200
>> Subject: [PATCH] x86: Early boot alternative instructions
>
> hm, patch is whitespace damaged.
>
> Also, the fix looks rather intrusive.
>
> Could we please disable the lockless slub code first and then do everything
> with proper testing and re-enable the lockless code *after* we know that the
> alternatives fixup change is robust, etc? That way there's no rush needed.
>
> There's a lot of code that could break from tweaking the alternatives code.

Just ignore this patch. As explained by Christoph, if alternative_io()
was the issue, we'd see the crash in kmem_cache_alloc().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
