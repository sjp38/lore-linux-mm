Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0890A8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:01:56 -0400 (EDT)
Date: Thu, 24 Mar 2011 13:01:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
In-Reply-To: <AANLkTimMcP-GikCCndQppNBsS7y=4beesZ4PaD6yh5y5@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103241300420.32226@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger> <20110324142146.GA11682@elte.hu> <alpine.DEB.2.00.1103240940570.32226@router.home> <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com> <20110324172653.GA28507@elte.hu>
 <alpine.DEB.2.00.1103241242450.32226@router.home> <AANLkTimMcP-GikCCndQppNBsS7y=4beesZ4PaD6yh5y5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Mar 2011, Pekka Enberg wrote:

> On Thu, Mar 24, 2011 at 7:43 PM, Christoph Lameter <cl@linux.com> wrote:
> > The bug should only trigger on old AMD64 boxes that do not support
> > cmpxchg16b.
>
> Yup. Ingo is it possible to see /proc/cpuinfo of one of the affected
> boxes? I'll try your config but I'm pretty sure the problem doesn't
> trigger here. Like I said, I think the problem is that alternative
> instructions are not patched early enough for cmpxchg16b emulation to
> work for kmem_cache_init(). I tried my check_bugs() patch but it hangs
> during boot. I'll see if I can cook up a patch that does
> alternative_instructions() before kmem_cache_init() because I think
> those *should* be available during boot too.

I forced the fallback to the _emu function to occur but could not trigger
the bug in kvm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
