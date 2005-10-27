MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17249.25537.622745.577885@wombat.chubb.wattle.id.au>
Date: Fri, 28 Oct 2005 09:33:21 +1000
From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
In-Reply-To: <20051027161602.38a4051b.akpm@osdl.org>
References: <1130366995.23729.38.camel@localhost.localdomain>
	<200510271038.52277.ak@suse.de>
	<20051027131725.GI5091@opteron.random>
	<1130425212.23729.55.camel@localhost.localdomain>
	<20051027151123.GO5091@opteron.random>
	<20051027112054.10e945ae.akpm@osdl.org>
	<20051027200434.GT5091@opteron.random>
	<20051027135058.2f72e706.akpm@osdl.org>
	<20051027213721.GX5091@opteron.random>
	<20051027152340.5e3ae2c6.akpm@osdl.org>
	<1130454352.23729.134.camel@localhost.localdomain>
	<20051027161602.38a4051b.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, andrea@suse.de, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Andrew" == Andrew Morton <akpm@osdl.org> writes:


Andrew> Can we do sys_fholepunch(int fd, loff_t offset, loff_t
Andrew> length)?  That requires that your applications know both the
Andrew> fd and the file offset.

Can we copy the SvR4 fcntl(int fd, F_FREESP, struct flock *lkp) ??
It'd ease the  porting burden for some things.


-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
