Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 08C116B0009
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 18:15:45 -0500 (EST)
MIME-Version: 1.0
Message-ID: <33082dbe-496e-47a0-8394-11d59ac17f87@default>
Date: Fri, 25 Jan 2013 15:15:30 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv2 8/9] zswap: add to mm/
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1357590280-31535-9-git-send-email-sjenning@linux.vnet.ibm.com>
 <51030ADA.8030403@redhat.com>
In-Reply-To: <51030ADA.8030403@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Rik van Riel [mailto:riel@redhat.com]
> Subject: Re: [PATCHv2 8/9] zswap: add to mm/
>=20
> On 01/07/2013 03:24 PM, Seth Jennings wrote:
> > zswap is a thin compression backend for frontswap. It receives
> > pages from frontswap and attempts to store them in a compressed
> > memory pool, resulting in an effective partial memory reclaim and
> > dramatically reduced swap device I/O.
> >
> > Additional, in most cases, pages can be retrieved from this
> > compressed store much more quickly than reading from tradition
> > swap devices resulting in faster performance for many workloads.
> >
> > This patch adds the zswap driver to mm/
> >
> > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>=20
> I like the approach of flushing pages into actual disk based
> swap when compressed swap is full.  I would like it if that
> was advertised more prominently in the changelog :)
>=20
> The code looks mostly good, complaints are at the nitpick level.
>=20
> One worry is that the pool can grow to whatever maximum was
> decided, and there is no way to shrink it when memory is
> required for something else.
>=20
> Would it be an idea to add a shrinker for the zcache pool,
> that can also shrink the zcache pool when required?
>=20
> Of course, that does lead to the question of how to balance
> the pressure from that shrinker, with the new memory entering
> zcache from the swap side. I have no clear answers here, just
> something to think about...

Hey Rik --

A shrinker needs to be able to free up whole pages.
I think Seth is working on this with zsmalloc but
it's quite a bit harder when pursuing high density
and page crossing which are the benefits, but also
part of the curse, of zsmalloc.

I have some ideas on how to do pressure balancing
and plan to propose a topic for LSF/MM to discuss
various questions involving in-kernel compression,
with this sub-topic included.  Hopefully all the
developers contributing various in-kernel compression
solutions will be able to attend and participate
and we can start converging on upstreaming (and/or
promoting) some of them.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
