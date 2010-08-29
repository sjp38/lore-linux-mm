Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C4CE96B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 09:17:36 -0400 (EDT)
Message-ID: <4C7A5DDE.8030106@kernel.org>
Date: Sun, 29 Aug 2010 16:17:18 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: 2.6.34.1 page allocation failure
References: <4C70BFF3.8030507@hardwarefreak.com> <alpine.DEB.1.10.1008220842400.8562@uplift.swm.pp.se> <AANLkTin48SJ58HvFqjrOnQBMqLcbECtqXokweV00dNgv@mail.gmail.com> <alpine.DEB.2.00.1008221734410.21916@router.home> <4C724141.8060000@kernel.org> <4C72F7C6.3020109@hardwarefreak.com> <4C74097A.5020504@kernel.org> <alpine.DEB.1.10.1008242114120.8562@uplift.swm.pp.se> <4C7A3B1D.7050500@kernel.org> <alpine.DEB.1.10.1008291433420.8562@uplift.swm.pp.se>
In-Reply-To: <alpine.DEB.1.10.1008291433420.8562@uplift.swm.pp.se>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Cc: Stan Hoeppner <stan@hardwarefreak.com>, Christoph Lameter <cl@linux.com>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Linux Netdev List <netdev@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

  On Sun, 29 Aug 2010, Pekka Enberg wrote:
>> Do you see these out-of-memory problems with 2.6.35?
On 29.8.2010 15.38, Mikael Abrahamsson wrote:
> Haven't tried it.
>
> Has there been substantial work done there that changes things so that 
> if I reproduce it on 2.6.35, someone will look into the issue in 
> earnest? Since I'll most likely have to compile a new kernel, are 
> there any debug options I should enable to give more information to 
> aid fault finding?
There aren't any debug options that need to be enabled. The reason I'm 
asking is because we had a bunch of similar issues being reported 
earlier that got fixed and it's been calm for a while. That's why it 
would be interesting to know if 2.6.35 or 2.6.36-rc2 (if it's not too 
unstable to test) fixes things.

             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
