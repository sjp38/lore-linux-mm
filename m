Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A04D08D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:27:22 -0400 (EDT)
Date: Thu, 24 Mar 2011 20:27:12 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
Message-ID: <20110324192712.GA7156@elte.hu>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
 <20110324142146.GA11682@elte.hu>
 <alpine.DEB.2.00.1103240940570.32226@router.home>
 <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
 <20110324172653.GA28507@elte.hu>
 <alpine.DEB.2.00.1103242011540.4990@tiger>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103242011540.4990@tiger>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Pekka Enberg <penberg@kernel.org> wrote:

> >From dd1534455196d2a8f6c9c912db614e59986c9f0e Mon Sep 17 00:00:00 2001
> From: Pekka Enberg <penberg@kernel.org>
> Date: Thu, 24 Mar 2011 19:59:35 +0200
> Subject: [PATCH] x86: Early boot alternative instructions

hm, patch is whitespace damaged.

Also, the fix looks rather intrusive.

Could we please disable the lockless slub code first and then do everything 
with proper testing and re-enable the lockless code *after* we know that the 
alternatives fixup change is robust, etc? That way there's no rush needed.

There's a lot of code that could break from tweaking the alternatives code.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
