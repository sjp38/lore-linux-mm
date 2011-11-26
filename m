Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 058D46B006C
	for <linux-mm@kvack.org>; Sat, 26 Nov 2011 05:59:29 -0500 (EST)
Received: by bke17 with SMTP id 17so6861150bke.14
        for <linux-mm@kvack.org>; Sat, 26 Nov 2011 02:59:26 -0800 (PST)
Message-ID: <1322305162.10212.8.camel@edumazet-laptop>
Subject: Re: [BUG] 3.2-rc2: BUG kmalloc-8: Redzone overwritten
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 26 Nov 2011 11:59:22 +0100
In-Reply-To: <1322304878.28191.1.camel@sasha>
References: <1321866845.3831.7.camel@lappy>
	 <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321870915.2552.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321870967.8173.1.camel@lappy> <1322304878.28191.1.camel@sasha>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: David Miller <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>

Le samedi 26 novembre 2011 A  12:54 +0200, Sasha Levin a A(C)crit :
> > On Mon, 2011-11-21 at 11:21 +0100, Eric Dumazet wrote:
> > > 
> > > Hmm, I forgot to remove the sock_hold(sk) call from dn_slow_timer(),
> > > here is V2 :
> > > 
> > > [PATCH] decnet: proper socket refcounting
> > > 
> > > Better use sk_reset_timer() / sk_stop_timer() helpers to make sure we
> > > dont access already freed/reused memory later.
> > > 
> > > Reported-by: Sasha Levin <levinsasha928@gmail.com>
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > > ---
> > 
> > 
> > Applied locally and running same tests as before, will update with
> > results.
> > 
> 
> Looks ok after a couple days of testing.
> 
> 	Tested-by: Sasha Levin <levinsasha928@gmail.com>
> 

Thanks Sasha !


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
