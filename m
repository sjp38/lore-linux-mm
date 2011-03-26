Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D1DEB8D0040
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 16:00:59 -0400 (EDT)
Date: Sat, 26 Mar 2011 21:00:50 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] slub: Disable the lockless allocator
Message-ID: <20110326200050.GA9689@elte.hu>
References: <20110324185258.GA28370@elte.hu>
 <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6>
 <20110324192247.GA5477@elte.hu>
 <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com>
 <20110326112725.GA28612@elte.hu>
 <20110326114736.GA8251@elte.hu>
 <1301161507.2979.105.camel@edumazet-laptop>
 <alpine.DEB.2.00.1103261406420.24195@router.home>
 <alpine.DEB.2.00.1103261428200.25375@router.home>
 <alpine.DEB.2.00.1103261440160.25375@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103261440160.25375@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Christoph Lameter <cl@linux.com> wrote:

> On Sat, 26 Mar 2011, Christoph Lameter wrote:
> 
> > Tejun: Whats going on there? I should be getting offsets into the per cpu
> > area and not kernel addresses.
> 
> Its a UP kernel running on dual Athlon. So its okay ... Argh.... The
> following patch fixes it by using the fallback code for cmpxchg_double:

The fix works here too:

Tested-by: Ingo Molnar <mingo@elte.hu>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
