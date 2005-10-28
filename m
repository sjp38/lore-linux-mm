Date: Thu, 27 Oct 2005 19:00:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-Id: <20051027190011.5503a297.akpm@osdl.org>
In-Reply-To: <43617E87.4040605@us.ibm.com>
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
	<20051028002231.GC5091@opteron.random>
	<20051027173243.41ecd335.akpm@osdl.org>
	<43617E87.4040605@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: andrea@suse.de, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> I am still not clear on the consensus here - the plan is go forward
>  with the patch (ofcourse, naming changes) and may be later add
>  (fd, offset, len) version of it through sys_holepunch ?

Spose so.  <mutter>.

Please ensure that the changlog captures everything which we've discussed.

>  If so, I can quickly redo my patch + I need to work out bugs in
>  shm_truncate_range().

Don't forget VM_NONLINEAR.   And VM_HUGETLB, VM_IO, VM_whatever come to that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
