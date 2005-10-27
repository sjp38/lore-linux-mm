MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17249.25225.582755.489919@wombat.chubb.wattle.id.au>
Date: Fri, 28 Oct 2005 09:28:09 +1000
From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
In-Reply-To: <20051027200434.GT5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain>
	<200510271038.52277.ak@suse.de>
	<20051027131725.GI5091@opteron.random>
	<1130425212.23729.55.camel@localhost.localdomain>
	<20051027151123.GO5091@opteron.random>
	<20051027112054.10e945ae.akpm@osdl.org>
	<20051027200434.GT5091@opteron.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, pbadari@us.ibm.com, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Andrea" == Andrea Arcangeli <andrea@suse.de> writes:

Andrea> On Thu, Oct 27, 2005 at 11:20:54AM -0700, Andrew Morton wrote:

Andrea> The idea is to implement a sys_truncate_range, but using the
Andrea> mappings so the user doesn't need to keep track of which parts
Andrea> of the file have to be truncated, and it only needs to know
Andrea> which part of the address space is obsolete. This will be the
Andrea> first API that allows to re-create holes in files.

The preexisting art is for the SysVr4 fcntl(fd, F_FREESP, &lk);
which frees space in the file covered by the struct flock * third
argument.   Depending on the fileystem, this may or may not work in
the middle of a file: it does for XFS, and could for tmpfs.  It always
works at the end of a file.  So that should be `first API in Linux'

Peter C


-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
