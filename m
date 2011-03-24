Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DA50B8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 13:27:01 -0400 (EDT)
Date: Thu, 24 Mar 2011 18:26:53 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
Message-ID: <20110324172653.GA28507@elte.hu>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
 <20110324142146.GA11682@elte.hu>
 <alpine.DEB.2.00.1103240940570.32226@router.home>
 <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Pekka Enberg <penberg@kernel.org> wrote:

> On Thu, Mar 24, 2011 at 4:41 PM, Christoph Lameter <cl@linux.com> wrote:
> > On Thu, 24 Mar 2011, Ingo Molnar wrote:
> >
> >> FYI, some sort of boot crash has snuck upstream in the last 24 hours:
> >>
> >>  BUG: unable to handle kernel paging request at ffff87ffc147e020
> >>  IP: [<ffffffff811aa762>] this_cpu_cmpxchg16b_emu+0x2/0x1c
> >
> > Hmmm.. This is the fallback code for the case that the processor does not
> > support cmpxchg16b.
> 
> How does alternative_io() work? Does it require
> alternative_instructions() to be executed. If so, the fallback code
> won't be active when we enter kmem_cache_init(). Is there any reason
> check_bugs() is called so late during boot? Can we do something like
> the totally untested attached patch?

Does the config i sent you boot on your box? I think the bug is pretty generic 
and should trigger on any box.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
