Date: Mon, 26 Nov 2001 16:29:58 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: kupdated high load with heavy disk I/O
Message-ID: <20011126162958.O14196@athlon.random>
References: <35F52ABC3317D511A55300D0B73EB8056FCC50@cinshrexc01.shermfin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35F52ABC3317D511A55300D0B73EB8056FCC50@cinshrexc01.shermfin.com>; from ARechenberg@shermanfinancialgroup.com on Mon, Nov 26, 2001 at 10:08:27AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rechenberg, Andrew" <ARechenberg@shermanfinancialgroup.com>
Cc: 'Ken Brownfield' <brownfld@irridia.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 26, 2001 at 10:08:27AM -0500, Rechenberg, Andrew wrote:
> Ken,
> 
> The 2.4.15pre7 kernel seems to have fixed my issue with kupdated and 4GB
> RAM.  We did some testing over the weekend and the box was still interactive
> with a load of 7+.  There still seems to be a lot of swapping going on
> though.  I've read from previous threads that 2.4 uses swap more readily
> than 2.2 did, but should it use 10% of my swap and have almost 8MB
> SwapCached?

if it only swapouts at a very slow rate over the time and it never
swapin, then yes it seems sane. You may also give a spin to 2.4.15aa1
that should swap a bit less.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
