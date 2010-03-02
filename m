Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB5D96B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 13:32:02 -0500 (EST)
Date: Tue, 2 Mar 2010 18:34:51 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Memory management woes - order 1 allocation failures
Message-ID: <20100302183451.75d44f03@lxorguk.ukuu.org.uk>
In-Reply-To: <20100302172606.GA11355@csn.ul.ie>
References: <alpine.DEB.2.00.1002261042020.7719@router.home>
	<84144f021002260917q61f7c255rf994425f3a613819@mail.gmail.com>
	<20100301103546.DD86.A69D9226@jp.fujitsu.com>
	<20100302172606.GA11355@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Greg Kroah-Hartman <gregkh@suse.de>, Christoph Lameter <cl@linux-foundation.org>, Frans Pop <elendil@planet.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

> For reasons that are not particularly clear to me, tty_buffer_alloc() is
> called far more frequently in 2.6.33 than in 2.6.24. I instrumented the
> function to print out the size of the buffers allocated, booted under
> qemu and would just "cat /bin/ls" to see what buffers were allocated.
> 2.6.33 allocates loads, including high-order allocations. 2.6.24
> appeared to allocate once and keep silent.

The pty layer is using them now and didn't before. That will massively
distort your numhers.

> While there have been snags recently with respect to high-order
> allocation failures in recent kernels, this might be one of the cases
> where it's due to subsystems requesting high-order allocations more.

The pty code certainly triggered more such allocations. I've sent Greg
patches to make the tty buffering layer allocate sensible sizes as it
doesn't need multiple page allocations in the first place.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
