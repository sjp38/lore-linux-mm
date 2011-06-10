Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F32976B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 22:52:57 -0400 (EDT)
Date: Fri, 10 Jun 2011 11:52:49 +0900
From: Simon Horman <horms@verge.net.au>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Message-ID: <20110610025249.GD643@verge.net.au>
References: <4DED344D.7000005@pandora.be>
 <4DED9C23.2030408@fnarfbargle.com>
 <4DEE27DE.7060004@trash.net>
 <4DEE3859.6070808@fnarfbargle.com>
 <4DEE4538.1020404@trash.net>
 <1307471484.3091.43.camel@edumazet-laptop>
 <4DEEACC3.3030509@trash.net>
 <4DEEBFC2.4060102@fnarfbargle.com>
 <1307505541.3102.12.camel@edumazet-laptop>
 <4DEFAB15.2060905@fnarfbargle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DEFAB15.2060905@fnarfbargle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <brad@fnarfbargle.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Patrick McHardy <kaber@trash.net>, Bart De Schuymer <bdschuym@pandora.be>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On Thu, Jun 09, 2011 at 01:02:13AM +0800, Brad Campbell wrote:
> On 08/06/11 11:59, Eric Dumazet wrote:
> 
> >Well, a bisection definitely should help, but needs a lot of time in
> >your case.
> 
> Yes. compile, test, crash, walk out to the other building to press
> reset, lather, rinse, repeat.
> 
> I need a reset button on the end of a 50M wire, or a hardware watchdog!

Not strictly on-topic, but in situations where I have machines
that either don't have lights-out facilities or have broken ones
I find that network controlled power switches to be very useful.

At one point I would have need an 8000km long wire to the reset switch :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
