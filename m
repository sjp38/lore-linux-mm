Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id E97356B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 18:49:07 -0500 (EST)
MIME-Version: 1.0
Message-ID: <b6ea78ee-41df-4c92-84fa-e1b4a430f957@default>
Date: Mon, 18 Feb 2013 15:48:47 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] zsmalloc: Add Kconfig for enabling PTE method
References: <1359937421-19921-1-git-send-email-minchan@kernel.org>
 <511F2721.2000305@gmail.com> <512271E1.9000105@linux.vnet.ibm.com>
In-Reply-To: <512271E1.9000105@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Ric Mason <ric.masonn@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH] zsmalloc: Add Kconfig for enabling PTE method
>=20
> On 02/16/2013 12:28 AM, Ric Mason wrote:
> > On 02/04/2013 08:23 AM, Minchan Kim wrote:
> >> +      for object mapping. You can check speed with zsmalloc
> >> benchmark[1].
> >> +      [1] https://github.com/spartacus06/zsmalloc
> >
> > Is there benchmark to test zcache? eg. internal fragmentation level ...
>=20
> First, zsmalloc is not used in zcache right now so just wanted to say
> that.  It is used in zram and the proposed zswap
> (https://lwn.net/Articles/528817/)
>=20
> There is not an official benchmark.  However anything that generates
> activity that will hit the frontswap or cleancache hooks will do.
> These are workloads that overcommit memory and use swap, or access
> file sets whose size is larger that the system page cache.

I think it's important to note that the question "is there
a benchmark" is a very deep and difficult question for any
compression solution because it is so workload-dependent.
Unlike many benchmarks that simply synthesize a _quantity_
of data, zcache/zswap/zram all are very sensitive to the
actual contents of that data as the compression ratio
varies widely depending on the data.  So we need to ensure
that the data used by any benchmark has similar "entropy"
to real world workloads.  I'm not sure how we can do that.

So it may or may not be useful to measure zcache/zswap/zram using
standard benchmarks (including things like SPECjbb).  At least
kernbench is something that kernel developers do every day,
so it is definitely a real world workload... but adding
parallel compiles (via "make -jN") until the system thrashes,
and then showing zcache/zswap/zram reduces the thrashing may
not be at all representative of a broad range of workloads
that cause memory pressure... kernbench is just convenient for
us developers to demonstrate that the mechanism works.

Ideas welcome... well-thought out ideas anyway!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
