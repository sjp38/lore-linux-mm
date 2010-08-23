Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 586AF6007EE
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 18:35:53 -0400 (EDT)
Message-ID: <4C72F7C6.3020109@hardwarefreak.com>
Date: Mon, 23 Aug 2010 17:35:50 -0500
From: Stan Hoeppner <stan@hardwarefreak.com>
MIME-Version: 1.0
Subject: Re: 2.6.34.1 page allocation failure
References: <4C70BFF3.8030507@hardwarefreak.com> <alpine.DEB.1.10.1008220842400.8562@uplift.swm.pp.se> <AANLkTin48SJ58HvFqjrOnQBMqLcbECtqXokweV00dNgv@mail.gmail.com> <alpine.DEB.2.00.1008221734410.21916@router.home> <4C724141.8060000@kernel.org>
In-Reply-To: <4C724141.8060000@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Mikael Abrahamsson <swmike@swm.pp.se>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Pekka Enberg put forth on 8/23/2010 4:37 AM:
>  On 8/23/10 1:40 AM, Christoph Lameter wrote:
>> On Sun, 22 Aug 2010, Pekka Enberg wrote:
>>
>>> In Stan's case, it's a order-1 GFP_ATOMIC allocation but there are
>>> only order-0 pages available. Mel, any recent page allocator fixes in
>>> 2.6.35 or 2.6.36-rc1 that Stan/Mikael should test?
>> This is the TCP slab? Best fix would be in the page allocator. However,
>> in this particular case the slub allocator would be able to fall back to
>> an order 0 allocation and still satisfy the request.
>>
> Looking at the stack trace of the oops, I think Stan has CONFIG_SLAB
> which doesn't have order-0 fallback.

That is correct.  The menuconfig help screen led me to believe the SLAB
allocator was the "safe" choice:

"CONFIG_SLAB:
The regular slab allocator that is established and known to work well in
all environments"

Should I be using SLUB instead?  Any downsides to SLUB on an old and
slow (500 MHz) single core dual CPU box with <512MB RAM?

Also, what is the impact of these oopses?  Despite the entries in dmesg,
the system "seems" to be running ok.  Or is this simply the calm before
the impending storm?

-- 
Stan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
