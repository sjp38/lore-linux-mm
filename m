MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17249.27103.749588.678959@wombat.chubb.wattle.id.au>
Date: Fri, 28 Oct 2005 09:59:27 +1000
From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
In-Reply-To: <20051027164959.61d04327.akpm@osdl.org>
References: <1130366995.23729.38.camel@localhost.localdomain>
	<200510271038.52277.ak@suse.de>
	<20051027131725.GI5091@opteron.random>
	<1130425212.23729.55.camel@localhost.localdomain>
	<20051027151123.GO5091@opteron.random>
	<20051027112054.10e945ae.akpm@osdl.org>
	<20051027200434.GT5091@opteron.random>
	<17249.25225.582755.489919@wombat.chubb.wattle.id.au>
	<20051027164959.61d04327.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, andrea@suse.de, pbadari@us.ibm.com, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Andrew" == Andrew Morton <akpm@osdl.org> writes:


Andrew> However if we did this we'd need to do a 64-bit version as
Andrew> well, using flock64.  Which means we really needn't bother
Andrew> with the 32-bit version, which means we're not
Andrew> svr4-compatible, unless svr4 also has a 64-bit version??

Yes it does.

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
