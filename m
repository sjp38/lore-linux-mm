Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA03588
	for <linux-mm@kvack.org>; Mon, 30 Sep 2002 11:24:35 -0700 (PDT)
Message-ID: <3D9896F6.8E584DC5@digeo.com>
Date: Mon, 30 Sep 2002 11:24:54 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.39-mm1
References: <3D9804E1.76C9D4AE@digeo.com> <766838976.1033378149@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> Which looks about the same to me? Me slightly confused.

I expect that with the node-local allocations you're not getting
a lot of benefit from the lock amortisation.  Anton will.

It's the lack of improvement of cache-niceness which is irksome.
Perhaps the heuristic should be based on recency-of-allocation and
not recency-of-freeing.  I'll play with that.

> Will try
> adding the original hot/cold stuff onto 39-mm1 if you like?

Well, it's all in the noise floor, isn't it?  Better off trying
broader tests.  I had a play with netperf and the chatroom
benchmark.  But the latter varied from 80,000 msgs/sec up
to 350,000 between runs.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
