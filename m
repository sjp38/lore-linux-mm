Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 050C7600044
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 18:40:55 -0400 (EDT)
Date: Sun, 22 Aug 2010 17:40:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 2.6.34.1 page allocation failure
In-Reply-To: <AANLkTin48SJ58HvFqjrOnQBMqLcbECtqXokweV00dNgv@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1008221734410.21916@router.home>
References: <4C70BFF3.8030507@hardwarefreak.com> <alpine.DEB.1.10.1008220842400.8562@uplift.swm.pp.se> <AANLkTin48SJ58HvFqjrOnQBMqLcbECtqXokweV00dNgv@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Mikael Abrahamsson <swmike@swm.pp.se>, Stan Hoeppner <stan@hardwarefreak.com>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Sun, 22 Aug 2010, Pekka Enberg wrote:

> In Stan's case, it's a order-1 GFP_ATOMIC allocation but there are
> only order-0 pages available. Mel, any recent page allocator fixes in
> 2.6.35 or 2.6.36-rc1 that Stan/Mikael should test?

This is the TCP slab? Best fix would be in the page allocator. However,
in this particular case the slub allocator would be able to fall back to
an order 0 allocation and still satisfy the request.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
