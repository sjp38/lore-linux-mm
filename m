Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA24977
	for <linux-mm@kvack.org>; Tue, 24 Mar 1998 18:39:15 -0500
Date: Tue, 24 Mar 1998 22:54:18 GMT
Message-Id: <199803242254.WAA03274@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Lazy page reclamation on SMP machines: memory barriers
In-Reply-To: <Pine.LNX.3.95.980323151332.431D-100000@penguin.transmeta.com>
References: <199803232249.WAA02431@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.95.980323151332.431D-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm@kvack.org, linux-smp@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 23 Mar 1998 15:20:11 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> Intel guarantees total ordering around any locked instruction, so the
> spinlocks themselves act as the barriers. 

Fine.  Can we assume that spinlocks and atomic set/clear_bit
instructions have the same semantics on other CPUs?

I'm in London until the weekend, but I hope to have the lazy page
stealing in a fit state to release shortly after getting back thanks to
this.

--Stephen
