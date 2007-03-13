Date: Wed, 14 Mar 2007 08:46:33 +1100
Message-ID: <87hcsoakau.wl%peterc@chubb.wattle.id.au>
From: Peter Chubb <peterc@chubb.wattle.id.au>
In-Reply-To: <45F7194B.5080705@goop.org>
References: <20070313200313.GG10459@waste.org>
	<45F706BC.7060407@goop.org>
	<20070313202125.GO10394@waste.org>
	<20070313.140722.72711732.davem@davemloft.net>
	<20070313211435.GP10394@waste.org>
	<45F7194B.5080705@goop.org>
Subject: Re: [QUICKLIST 0/4] Arch independent quicklists V2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>, ianw@gelato.unsw.edu.au
Cc: Matt Mackall <mpm@selenic.com>, David Miller <davem@davemloft.net>, nickpiggin@yahoo.com.au, akpm@linux-foundation.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>>>> "Jeremy" == Jeremy Fitzhardinge <jeremy@goop.org> writes:


Jeremy> And do the same in pte pages for actual mapped pages?  Or do
Jeremy> you think they would be too densely populated for it to be
Jeremy> worthwhile?

We've been doing some measurements on how densely clumped ptes are.
On 32-bit platforms, they're pretty dense.  On IA64, quite a bit
sparser, depending on the workload of course.  I think that's mostly because
of the larger pagesize on IA64 -- with 64k pages, you don't need very
many to map a small object.

I'm hoping IanW can give more details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
