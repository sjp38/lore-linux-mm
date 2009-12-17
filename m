Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 814D86B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:08:17 -0500 (EST)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBHIuWxR009794
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 13:56:32 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHJ86AR946298
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:08:06 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHJ84Uj004502
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:08:05 -0500
Date: Thu, 17 Dec 2009 11:08:04 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-ID: <20091217190804.GB6788@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20091216101107.GA15031@basil.fritz.box> <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com> <20091216102806.GC15031@basil.fritz.box> <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com> <1261004224.21028.500.camel@laptop> <20091217084046.GA9804@basil.fritz.box> <1261039534.27920.67.camel@laptop> <20091217085430.GG9804@basil.fritz.box> <20091217144551.GA6819@linux.vnet.ibm.com> <20091217175338.GL9804@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091217175338.GL9804@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 06:53:39PM +0100, Andi Kleen wrote:
> > OK, I have to ask...
> > 
> > Why not just use the already-existing SRCU in this case?
> 
> You right, SRCU could work. 
> 
> Still needs a lot more work of course.

As discussed with Peter on IRC, I have been idly thinking about how I
would implement SRCU if I were starting on it today.  If you would like
to see some specific improvements to SRCU, telling me about them would
greatly increase the probability of my doing something about them.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
