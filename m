MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17155.52686.309135.906824@wombat.chubb.wattle.id.au>
Date: Thu, 18 Aug 2005 09:52:46 +1000
From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: Re: pagefault scalability patches
In-Reply-To: <20050817164456.77e8b85e.akpm@osdl.org>
References: <20050817151723.48c948c7.akpm@osdl.org>
	<Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
	<Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0508171559350.3553@g5.osdl.org>
	<Pine.LNX.4.62.0508171603240.19363@schroedinger.engr.sgi.com>
	<20050817163030.15e819dd.akpm@osdl.org>
	<Pine.LNX.4.62.0508171631160.19528@schroedinger.engr.sgi.com>
	<20050817164456.77e8b85e.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, torvalds@osdl.org, hugh@veritas.com, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Andrew" == Andrew Morton <akpm@osdl.org> writes:

Andrew> The decreases in system CPU time for the single-threaded case
Andrew> are extraordinarily high.  

Are the sizes of the test the same?  The unpatched version says 16G,
the patched one 4G --- with a quarter the memory size I'd expect less
than a quarter of the overhead...

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
