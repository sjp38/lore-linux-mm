Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 477A66B0033
	for <linux-mm@kvack.org>; Wed, 15 May 2013 15:36:26 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <57917f43-ab37-4e82-b659-522e427fda7f@default>
Date: Wed, 15 May 2013 12:35:58 -0700 (PDT)
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
In-Reply-To: <20130515185506.GA23342@phenom.dumpdata.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Konrad Rzeszutek Wilk
> Subject: Re: [PATCHv11 3/4] zswap: add to mm/
>=20
> > Sorry, but I don't think that's appropriate for a patch in the MM subsy=
stem.
>=20
> I am heading to the airport shortly so this email is a bit hastily typed.
>=20
> Perhaps a compromise can be reached where this code is merged as a driver
> not a core mm component. There is a high bar to be in the MM - it has to
> work with many many different configurations.
>=20
> And drivers don't have such a high bar. They just need to work on a speci=
fic
> issue and that is it. If zswap ended up in say, drivers/mm that would mak=
e
> it more palpable I think.
>=20
> Thoughts?

Hmmm...

To me, that sounds like a really good compromise.  Then anyone
who wants to experiment with compressed swap pages can do so by
enabling the zswap driver.  And the harder problem of deeply integrating
compression into the MM subsystem can proceed in parallel
by leveraging and building on the best of zswap and zcache
and zram.

Seth, if you want to re-post zswap as a driver... even a
previous zswap version with zsmalloc and without writeback...
I would be willing to ack it.  If I correctly understand
Mel's concerns, I suspect he might feel the same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
