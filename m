Date: Sat, 12 Jul 2008 15:28:39 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: swapon/swapoff in a loop -- ever-decreasing priority field
In-Reply-To: <Pine.LNX.4.64.0807112214240.25357@blonde.site>
References: <20080711121227.F694.KOSAKI.MOTOHIRO@jp.fujitsu.com> <Pine.LNX.4.64.0807112214240.25357@blonde.site>
Message-Id: <20080712152050.F69F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Vegard Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, 11 Jul 2008, KOSAKI Motohiro wrote:
> > > 
> > > I find that running swapon/swapoff in a loop will decrement the
> > > "Priority" field of the swap partition once per iteration. This
> > > doesn't seem quite correct, as it will eventually lead to an
> > > underflow.
> > > 
> > > (Though, by my calculations, it would take around 620 days of constant
> > > swapoff/swapon to reach this condition, so it's hardly a real-life
> > > problem.)
> > > 
> > > Is this something that should be fixed, though?
> > 
> > I am not sure about your intention.
> > Do following patch fill your requirement?
> 
> I believe that only handles a simple swapon/swapoff of one area:
> once you have a pair of them (which is very useful for swapoff
> testing: swapon Y before swapoff X so you can be sure there will
> be enough space) their priorities will again decrement indefinitely.
> Here's my version...

Yeah, I ignored intentionally its corner case.
I thought it is artificial issue, not real problem.
but yes, two swap test should be allowed.

your patch is better, of cource.
it works well on my sevarl test and I found no bug in my review.

Thanks!

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
