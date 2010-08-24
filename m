Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1D2746B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 13:12:01 -0400 (EDT)
Date: Tue, 24 Aug 2010 12:13:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 2.6.34.1 page allocation failure
In-Reply-To: <4C72F7C6.3020109@hardwarefreak.com>
Message-ID: <alpine.DEB.2.00.1008241210570.3695@router.home>
References: <4C70BFF3.8030507@hardwarefreak.com> <alpine.DEB.1.10.1008220842400.8562@uplift.swm.pp.se> <AANLkTin48SJ58HvFqjrOnQBMqLcbECtqXokweV00dNgv@mail.gmail.com> <alpine.DEB.2.00.1008221734410.21916@router.home> <4C724141.8060000@kernel.org>
 <4C72F7C6.3020109@hardwarefreak.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Stan Hoeppner <stan@hardwarefreak.com>
Cc: Pekka Enberg <penberg@kernel.org>, Mikael Abrahamsson <swmike@swm.pp.se>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Aug 2010, Stan Hoeppner wrote:

> Should I be using SLUB instead?  Any downsides to SLUB on an old and
> slow (500 MHz) single core dual CPU box with <512MB RAM?

SLUB has a smaller memory footprint so you may come out ahead for
such a small system in particular.

> Also, what is the impact of these oopses?  Despite the entries in dmesg,
> the system "seems" to be running ok.  Or is this simply the calm before
> the impending storm?

The system does not guarantee that GFP_ATOMIC allocation succeed so any
caller must provide logic to fall back if no memory is allocated. So the
effect may just be that certain OS operations have to be retried.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
