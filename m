Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B7CD06B0078
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 18:31:02 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o22NV2kZ001026
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 3 Mar 2010 08:31:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DFD745DE55
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 08:31:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CD3E45DE4C
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 08:31:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 169791DB8019
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 08:31:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BFC101DB8014
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 08:31:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Memory management woes - order 1 allocation failures
In-Reply-To: <20100302183451.75d44f03@lxorguk.ukuu.org.uk>
References: <20100302172606.GA11355@csn.ul.ie> <20100302183451.75d44f03@lxorguk.ukuu.org.uk>
Message-Id: <20100303082239.D614.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  3 Mar 2010 08:31:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Pekka Enberg <penberg@cs.helsinki.fi>, Greg Kroah-Hartman <gregkh@suse.de>, Christoph Lameter <cl@linux-foundation.org>, Frans Pop <elendil@planet.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

> > For reasons that are not particularly clear to me, tty_buffer_alloc() is
> > called far more frequently in 2.6.33 than in 2.6.24. I instrumented the
> > function to print out the size of the buffers allocated, booted under
> > qemu and would just "cat /bin/ls" to see what buffers were allocated.
> > 2.6.33 allocates loads, including high-order allocations. 2.6.24
> > appeared to allocate once and keep silent.
> 
> The pty layer is using them now and didn't before. That will massively
> distort your numhers.
> 
> > While there have been snags recently with respect to high-order
> > allocation failures in recent kernels, this might be one of the cases
> > where it's due to subsystems requesting high-order allocations more.
> 
> The pty code certainly triggered more such allocations. I've sent Greg
> patches to make the tty buffering layer allocate sensible sizes as it
> doesn't need multiple page allocations in the first place.

Wow, great! :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
