Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j2T0o4ps029297
	for <linux-mm@kvack.org>; Mon, 28 Mar 2005 19:50:04 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2T0o36J062666
	for <linux-mm@kvack.org>; Mon, 28 Mar 2005 19:50:03 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j2T0o3oh002573
	for <linux-mm@kvack.org>; Mon, 28 Mar 2005 19:50:03 -0500
Date: Mon, 28 Mar 2005 16:45:43 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC][PATCH] tunable zone watermarks
Message-ID: <183780000.1112057143@flay>
In-Reply-To: <20050328195143.GJ29310@logos.cnet>
References: <2c1942a70503272243c351eee@mail.gmail.com> <160420000.1112038232@flay> <20050328195143.GJ29310@logos.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Levent Serinol <lserinol@gmail.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Mon, Mar 28, 2005 at 11:30:32AM -0800, Martin J. Bligh wrote:
>> What situations do you want to tune them in? Would be nicer to do this
>> automagically ...
> 
> We do it automagically right now. What do you mean?
> 
> It is useful for testing purpose - but then you need an understanding of
> MM internals to make good use of it.
> 
> The only tweak available now is lowmem_reserve.
> 
> I'm sure there are loads where the default watermark values are 
> not optimal.

Yeah, I'm just not at all convinced that the solution to these problems
is to make everything tunable up the wazoo ... all that seems to do is

1) Encourage customers to break their systems in new and interesting ways
2) Line the pockets of "tuning consultants".

If there are loads where the default watermark values are not optimal
(and I agree there probably are) then what we really need is to auto
recognise those, and fix them in the OS ... rather than provide a tweakable.

I see that being able to poke those is useful in diagnosing the above ...
just not sure we want those in mainline. Perhaps we should have 
CONFIG_TWEAK_EVERYTHING_UP_THE_WAZOO and not enable it in distros,
or by default. But as an IBM employee, I can assure you IBM would 
whine mercilessly at the distros until they turned it on, so I'm not 
sure it helps ;-)

I've been in customer situations dealing with 10 billion tunables before,
it makes life impossible ;-(

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
