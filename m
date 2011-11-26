Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4C52B6B002D
	for <linux-mm@kvack.org>; Sat, 26 Nov 2011 05:54:47 -0500 (EST)
Received: by wwg38 with SMTP id 38so6466108wwg.26
        for <linux-mm@kvack.org>; Sat, 26 Nov 2011 02:54:44 -0800 (PST)
Subject: Re: [BUG] 3.2-rc2: BUG kmalloc-8: Redzone overwritten
From: Sasha Levin <levinsasha928@gmail.com>
In-Reply-To: <1321870967.8173.1.camel@lappy>
References: <1321866845.3831.7.camel@lappy>
	 <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321870915.2552.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321870967.8173.1.camel@lappy>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Sat, 26 Nov 2011 12:54:38 +0200
Message-ID: <1322304878.28191.1.camel@sasha>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>

On Mon, 2011-11-21 at 12:22 +0200, Sasha Levin wrote:
> On Mon, 2011-11-21 at 11:21 +0100, Eric Dumazet wrote:
> > Le lundi 21 novembre 2011 a 11:15 +0100, Eric Dumazet a ecrit :
> > 
> > > 
> > > Hmm, trinity tries to crash decnet ;)
> > > 
> > > Maybe we should remove this decnet stuff for good instead of tracking
> > > all bugs just for the record. Is there anybody still using decnet ?
> > > 
> > > For example dn_start_slow_timer() starts a timer without holding a
> > > reference on struct sock, this is highly suspect.
> > > 
> > > [PATCH] decnet: proper socket refcounting
> > > 
> > > Better use sk_reset_timer() / sk_stop_timer() helpers to make sure we
> > > dont access already freed/reused memory later.
> > > 
> > > Reported-by: Sasha Levin <levinsasha928@gmail.com>
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > 
> > Hmm, I forgot to remove the sock_hold(sk) call from dn_slow_timer(),
> > here is V2 :
> > 
> > [PATCH] decnet: proper socket refcounting
> > 
> > Better use sk_reset_timer() / sk_stop_timer() helpers to make sure we
> > dont access already freed/reused memory later.
> > 
> > Reported-by: Sasha Levin <levinsasha928@gmail.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> 
> [snip]
> 
> Applied locally and running same tests as before, will update with
> results.
> 

Looks ok after a couple days of testing.

	Tested-by: Sasha Levin <levinsasha928@gmail.com>

-- 

Sasha.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
