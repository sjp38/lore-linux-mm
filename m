Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id B789138CF4
	for <linux-mm@kvack.org>; Thu,  9 Aug 2001 17:47:35 -0300 (EST)
Date: Thu, 9 Aug 2001 17:47:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Swapping for diskless nodes
In-Reply-To: <20010809125033.E1200@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.33L.0108091740470.1439-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Aug 2001, Ingo Oeser wrote:

> Are there any races I have to consider?

Well, this IS a big issue against swap over network.

Swap over network is inherently prone to deadlock
situations, due to the following three problems:

1) we swap pages out when we are close to running
   out of free memory
2) to write pages out over the network, we need to
   allocate space to assemble network packets
3) we need to have memory to receive the ACKs on
   the packets we sent out

The only real solution to this would be memory
reservations so we know this memory won't be used
for other purposes.

What we can do right now is be careful about how
many writeouts over the network we do at the same
time, but that will still get us killed in case of
a ping flood ;)

regards,

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
