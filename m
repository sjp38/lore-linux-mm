Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 83A4F6B000A
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 10:50:24 -0500 (EST)
MIME-Version: 1.0
Message-ID: <9e251fb2-be82-41d2-b6cd-e46525b263cb@default>
Date: Thu, 21 Feb 2013 07:50:06 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv6 0/8] zswap: compressed swap caching
References: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: [PATCHv6 0/8] zswap: compressed swap caching
>=20
> Changelog:
>=20
> v6:
> * fix improper freeing of rbtree (Cody)

Cody's bug fix reminded me of a rather fundamental question:

Why does zswap use a rbtree instead of a radix tree?

Intuitively, I'd expect that pgoff_t values would
have a relatively high level of locality AND at any one time
the set of stored pgoff_t values would be relatively non-sparse.
This would argue that a radix tree would result in fewer nodes
touched on average for lookup/insert/remove.

Do you have evidence that rbtree is better here?
(Preferably over a set of workloads larger than
kernbench and SPECjbb ;-)  Or are there other
important design issues that disqualify a radix tree?

In the end, I guess either one (rbtree or radix tree)
will work, but it would be nice to get this kind of
fundamental design issue properly solved before merging
is to be considered.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
