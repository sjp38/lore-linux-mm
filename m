Message-Id: <20061130101451.495412000@chello.nl>>
Date: Thu, 30 Nov 2006 11:14:51 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 0/6] VM deadlock avoidance -v9
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Hi,

I have a new version of these patches; I'm still using SOCK_VMIO socket
tagging and skb->emergency marks, since I have not come up with another
approach that might work and my RFC to netdev has so far been ignored.

Other than this though, it changed quite a bit;

 - I now use the regular allocation paths and cover all allocations
needed to process a skb (although the RX pool sizing might need more
variables)

 - The emergency RX pool size is based on ip[46]frag_high_thresh and
ip[46]_rt_max_size so that fragment assembly and dst route cache
allocations cannot exhaust the memory. (more paths need analysis xfrm,
conntrack?)

 - skb->emergency packets skip taps

 - skb->emergency packets warn about and ignores NF_QUEUE targets

The patches definitely need more work but would you agree with the
general direction I'm working in or would you suggest yet another
direction?

Kind regards,

Peter


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
