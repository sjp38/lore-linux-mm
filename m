Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8653E8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 13:43:29 -0400 (EDT)
Date: Thu, 24 Mar 2011 12:43:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
In-Reply-To: <20110324172653.GA28507@elte.hu>
Message-ID: <alpine.DEB.2.00.1103241242450.32226@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger> <20110324142146.GA11682@elte.hu> <alpine.DEB.2.00.1103240940570.32226@router.home> <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com> <20110324172653.GA28507@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Mar 2011, Ingo Molnar wrote:

> > How does alternative_io() work? Does it require
> > alternative_instructions() to be executed. If so, the fallback code
> > won't be active when we enter kmem_cache_init(). Is there any reason
> > check_bugs() is called so late during boot? Can we do something like
> > the totally untested attached patch?
>
> Does the config i sent you boot on your box? I think the bug is pretty generic
> and should trigger on any box.

The bug should only trigger on old AMD64 boxes that do not support
cmpxchg16b.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
