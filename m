Date: Fri, 28 Oct 2005 09:56:00 +1000
From: Nathan Scott <nathans@sgi.com>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051028095600.Y6002974@wobbly.melbourne.sgi.com>
References: <1130366995.23729.38.camel@localhost.localdomain> <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random> <1130425212.23729.55.camel@localhost.localdomain> <20051027151123.GO5091@opteron.random> <20051027112054.10e945ae.akpm@osdl.org> <20051027200434.GT5091@opteron.random> <17249.25225.582755.489919@wombat.chubb.wattle.id.au> <20051027164959.61d04327.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051027164959.61d04327.akpm@osdl.org>; from akpm@osdl.org on Thu, Oct 27, 2005 at 04:49:59PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, andrea@suse.de, pbadari@us.ibm.com, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 27, 2005 at 04:49:59PM -0700, Andrew Morton wrote:
> Peter Chubb <peterc@gelato.unsw.edu.au> wrote:
> > The preexisting art is for the SysVr4 fcntl(fd, F_FREESP, &lk);
> > which frees space in the file covered by the struct flock * third
> > argument.
> 
> Thanks.  That's a rather klunky API but it'd be straightforward enough to
> implement.
> 
> However if we did this we'd need to do a 64-bit version as well, using
> flock64.  Which means we really needn't bother with the 32-bit version,
> which means we're not svr4-compatible, unless svr4 also has a 64-bit
> version??

There is, at least on IRIX (F_FREESP64).  Agreed on the API klunkiness
though ... its really not pretty. :|  Personally, I'd recommend going
with a sane API, and perhaps emulating the other on top of it if need
be.

cheers.

-- 
Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
