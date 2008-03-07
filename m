Subject: Re: [PATCH 00/28] Swap over NFS -v16
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1204888675.8514.102.camel@twins>
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
	 <18372.64081.995262.986841@notabene.brown>
	 <1204099113.6242.353.camel@lappy> <1837 <1204626509.6241.39.camel@lappy>
	 <18384.46967.583615.711455@notabene.brown>
	 <1204888675.8514.102.camel@twins>
Content-Type: text/plain
Date: Fri, 07 Mar 2008 12:55:31 +0100
Message-Id: <1204890931.8514.107.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-03-07 at 12:17 +0100, Peter Zijlstra wrote:

> That would be so if the whole path from RX to socket demux would have
> hard-irqs disabled. However I didn't see that. Moreover I think the
> whole purpose of the NetPoll interface is to allow some RX queueing to
> cut down on softirq overhead.

s/NetPoll/NAPI/

More specifically look at net/core/dev.c:netif_rx()
It has a input queue per device.

> >   2/ If the host is routing network packets, then incoming packets
> >      might go on an outbound queue.  Is this space limited?  and
> >      included in the reserve?
> 
> Not sure, somewhere along the routing code I lost it again. Constructive
> input from someone versed in that part of the kernel would be most
> welcome.

To clarify, I think we just send it on as I saw no reason why that could
fail. However the more fancy stuff like engress or QoS might spoil the
party, that is where I lost track.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
