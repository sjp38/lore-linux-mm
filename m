Received: from dm.cobaltmicro.com (davem@dm.cobaltmicro.com [209.133.34.35])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA25042
	for <linux-mm@kvack.org>; Tue, 24 Mar 1998 18:49:12 -0500
Date: Tue, 24 Mar 1998 15:45:21 -0800
Message-Id: <199803242345.PAA02702@dm.cobaltmicro.com>
From: "David S. Miller" <davem@dm.cobaltmicro.com>
In-reply-to: <199803242254.WAA03274@dax.dcs.ed.ac.uk> (sct@dcs.ed.ac.uk)
Subject: Re: Lazy page reclamation on SMP machines: memory barriers
References: <199803232249.WAA02431@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.95.980323151332.431D-100000@penguin.transmeta.com> <199803242254.WAA03274@dax.dcs.ed.ac.uk>
Sender: owner-linux-mm@kvack.org
To: sct@dcs.ed.ac.uk
Cc: torvalds@transmeta.com, linux-mm@kvack.org, linux-smp@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

   Date: 	Tue, 24 Mar 1998 22:54:18 GMT
   From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>

   > Intel guarantees total ordering around any locked instruction, so
   > the spinlocks themselves act as the barriers. 

   Fine.  Can we assume that spinlocks and atomic set/clear_bit
   instructions have the same semantics on other CPUs?

Yes, you certainly can for spinlocks.

Later,
David S. Miller
davem@dm.cobaltmicro.com
