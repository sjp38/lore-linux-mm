Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id B41D36B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 16:53:02 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <234e96e5-93ca-4739-a6ca-043272357c78@default>
Date: Wed, 15 May 2013 13:52:42 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv11 3/4] zswap: add to mm/
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <15c5b1da-132a-4c9e-9f24-bc272d3865d5@default>
 <20130514163541.GC4024@medulla>
 <f0272a06-141a-4d33-9976-ee99467f3aa2@default>
 <20130514225501.GA11956@cerebellum>
 <4d74f5db-11c1-4f58-97f4-8d96bbe601ac@default>
 <20130515185506.GA23342@phenom.dumpdata.com>
 <20130515200942.GA17724@cerebellum>
In-Reply-To: <20130515200942.GA17724@cerebellum>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Sent: Wednesday, May 15, 2013 2:10 PM
> To: Konrad Rzeszutek Wilk
> Cc: Dan Magenheimer; Andrew Morton; Greg Kroah-Hartman; Nitin Gupta; Minc=
han Kim; Robert Jennings;
> Jenifer Hopper; Mel Gorman; Johannes Weiner; Rik van Riel; Larry Woodman;=
 Benjamin Herrenschmidt; Dave
> Hansen; Joe Perches; Joonsoo Kim; Cody P Schafer; Hugh Dickens; Paul Mack=
erras; linux-mm@kvack.org;
> linux-kernel@vger.kernel.org; devel@driverdev.osuosl.org
> Subject: Re: [PATCHv11 3/4] zswap: add to mm/
>=20
> On Wed, May 15, 2013 at 02:55:06PM -0400, Konrad Rzeszutek Wilk wrote:
> > > Sorry, but I don't think that's appropriate for a patch in the MM sub=
system.
> >
> > I am heading to the airport shortly so this email is a bit hastily type=
d.
> >
> > Perhaps a compromise can be reached where this code is merged as a driv=
er
> > not a core mm component. There is a high bar to be in the MM - it has t=
o
> > work with many many different configurations.
> >
> > And drivers don't have such a high bar. They just need to work on a spe=
cific
> > issue and that is it. If zswap ended up in say, drivers/mm that would m=
ake
> > it more palpable I think.
> >
> > Thoughts?
>=20
> zswap, the writeback code particularly, depends on a number of non-export=
ed
> kernel symbols, namely:
>=20
> swapcache_free
> __swap_writepage
> __add_to_swap_cache
> swapcache_prepare
> swapper_spaces
>=20
> So it can't currently be built as a module and I'm not sure what the MM
> folks would think about exporting them and making them part of the KABI.

It can be built as a module if writeback is disabled (or ifdef'd by
a CONFIG_ZSWAP_WRITEBACK which depends on CONFIG_ZSWAP=3Dy).  The
folks at LSFMM who were planning to use zswap will be turning
off writeback anyway so an alternate is to pull writeback out
of zswap completely for now, since you don't really have a good
policy to manage it yet anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
