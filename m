Date: Wed, 28 Aug 2002 21:27:39 +0200
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [BUG] 2.5.30 swaps with no swap device mounted!!
Message-ID: <20020828192739.GB10487@atrey.karlin.mff.cuni.cz>
References: <20020827135421.A39@toy.ucw.cz> <Pine.LNX.4.44.0208280708020.3234-100000@hawkeye.luckynet.adm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0208280708020.3234-100000@hawkeye.luckynet.adm>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thunder from the hill <thunder@lightweight.ods.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > > It might be interesting to see what happens if you unplug the swap device 
> > > after umounting.
> > 
> > In the same way it might be interesting to see what happens if you put
> > cigarette into gasoline tank?
> 
> Well, you never know what unregistering does. It might happen to be 
> ignored for swap, once unregistered.

I guess it will crash and burn, I'd suggest at least unmounting all
filesystems prior to that test.
								Pavel
-- 
Casualities in World Trade Center: ~3k dead inside the building,
cryptography in U.S.A. and free speech in Czech Republic.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
