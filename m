Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5EB6B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 08:38:26 -0400 (EDT)
Date: Sun, 29 Aug 2010 14:38:21 +0200 (CEST)
From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: 2.6.34.1 page allocation failure
In-Reply-To: <4C7A3B1D.7050500@kernel.org>
Message-ID: <alpine.DEB.1.10.1008291433420.8562@uplift.swm.pp.se>
References: <4C70BFF3.8030507@hardwarefreak.com> <alpine.DEB.1.10.1008220842400.8562@uplift.swm.pp.se> <AANLkTin48SJ58HvFqjrOnQBMqLcbECtqXokweV00dNgv@mail.gmail.com> <alpine.DEB.2.00.1008221734410.21916@router.home> <4C724141.8060000@kernel.org>
 <4C72F7C6.3020109@hardwarefreak.com> <4C74097A.5020504@kernel.org> <alpine.DEB.1.10.1008242114120.8562@uplift.swm.pp.se> <4C7A3B1D.7050500@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Stan Hoeppner <stan@hardwarefreak.com>, Christoph Lameter <cl@linux.com>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Linux Netdev List <netdev@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Aug 2010, Pekka Enberg wrote:

> Do you see these out-of-memory problems with 2.6.35?

Haven't tried it.

Has there been substantial work done there that changes things so that if 
I reproduce it on 2.6.35, someone will look into the issue in earnest? 
Since I'll most likely have to compile a new kernel, are there any debug 
options I should enable to give more information to aid fault finding?

I'll start with the .config file from Ubuntu 10.04 2.6.32 kernel and 
oldconfig from there.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
