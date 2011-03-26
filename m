Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8ABB18D0040
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 15:18:25 -0400 (EDT)
Date: Sat, 26 Mar 2011 14:18:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Disable the lockless allocator
In-Reply-To: <1301161507.2979.105.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1103261406420.24195@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>  <20110324142146.GA11682@elte.hu>  <alpine.DEB.2.00.1103240940570.32226@router.home>  <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>  <20110324172653.GA28507@elte.hu> <20110324185258.GA28370@elte.hu>
  <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6>  <20110324192247.GA5477@elte.hu>  <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com>  <20110326112725.GA28612@elte.hu>  <20110326114736.GA8251@elte.hu>
 <1301161507.2979.105.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 26 Mar 2011, Eric Dumazet wrote:

> address : RSI = ffff88003ffc2020
>
> RSI is supposed to be a dynamic percpu addr
> Yet this value seems pretty outside of pcpu pools
>
> CR2: ffff87ffc1fdd020

Right. RSI should be in the range of the values you printed.
However, the determination RSI is independent of the emulation of the
instruction. If RSI is set wrong then we should see these failures on
machines that do not do the instruction emulation. A kvm run with Ingo's
config should show the same issues. Will do that now.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
