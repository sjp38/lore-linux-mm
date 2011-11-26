Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E34C6B0096
	for <linux-mm@kvack.org>; Sat, 26 Nov 2011 15:50:33 -0500 (EST)
Date: Sat, 26 Nov 2011 15:50:28 -0500 (EST)
Message-Id: <20111126.155028.1986754382924402334.davem@davemloft.net>
Subject: Re: [BUG] 3.2-rc2: BUG kmalloc-8: Redzone overwritten
From: David Miller <davem@davemloft.net>
In-Reply-To: <1321873110.2710.13.camel@menhir>
References: <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321870915.2552.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321873110.2710.13.camel@menhir>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: swhiteho@redhat.com
Cc: eric.dumazet@gmail.com, levinsasha928@gmail.com, mpm@selenic.com, cl@linux-foundation.org, penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, ccaulfie@redhat.com

From: Steven Whitehouse <swhiteho@redhat.com>
Date: Mon, 21 Nov 2011 10:58:30 +0000

> I have to say that I've been wondering lately whether it has got to the
> point where it is no longer useful. Has anybody actually tested it
> lately against "real" DEC implementations?

I doubt it :-)

If we can't think of any real reason to keep it around, let's try
to reach a quirk consensus and I'll toss it from the net-next tree.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
