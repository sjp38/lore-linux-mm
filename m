Date: Tue, 27 Aug 2002 13:54:22 +0000
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [BUG] 2.5.30 swaps with no swap device mounted!!
Message-ID: <20020827135421.A39@toy.ucw.cz>
References: <20020819105520.GK18350@holomorphy.com> <Pine.LNX.4.44.0208200655040.3234-100000@hawkeye.luckynet.adm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.44.0208200655040.3234-100000@hawkeye.luckynet.adm>; from thunder@lightweight.ods.org on Tue, Aug 20, 2002 at 06:55:35AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thunder from the hill <thunder@lightweight.ods.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > Due to the natural slab shootdown laziness issues, I turned off swap.
> > The kernel reported that it had successfully unmounted the swap device,
> > and for several days ran without it. Tonight, it went 91MB into swap
> > on the supposedly unmounted swap device!
> 
> It might be interesting to see what happens if you unplug the swap device 
> after umounting.

In the same way it might be interesting to see what happens if you put
cigarette into gasoline tank?
								Pavel

-- 
Philips Velo 1: 1"x4"x8", 300gram, 60, 12MB, 40bogomips, linux, mutt,
details at http://atrey.karlin.mff.cuni.cz/~pavel/velo/index.html.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
