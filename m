Message-ID: <4248BCFD.80909@yahoo.com.au>
Date: Tue, 29 Mar 2005 12:27:09 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] tunable zone watermarks
References: <2c1942a70503272243c351eee@mail.gmail.com> <160420000.1112038232@flay> <20050328195143.GJ29310@logos.cnet> <183780000.1112057143@flay>
In-Reply-To: <183780000.1112057143@flay>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Levent Serinol <lserinol@gmail.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:

>>On Mon, Mar 28, 2005 at 11:30:32AM -0800, Martin J. Bligh wrote:
>>
>>>What situations do you want to tune them in? Would be nicer to do this
>>>automagically ...
>>>
>>We do it automagically right now. What do you mean?
>>
>>It is useful for testing purpose - but then you need an understanding of
>>MM internals to make good use of it.
>>
>>The only tweak available now is lowmem_reserve.
>>
>>

min_free_kbytes is closer to what you want (sorry if it has already
been mentioned).

>>I'm sure there are loads where the default watermark values are 
>>not optimal.
>>
>
>Yeah, I'm just not at all convinced that the solution to these problems
>is to make everything tunable up the wazoo ... all that seems to do is
>
>1) Encourage customers to break their systems in new and interesting ways
>2) Line the pockets of "tuning consultants".
>
>If there are loads where the default watermark values are not optimal
>(and I agree there probably are) then what we really need is to auto
>recognise those, and fix them in the OS ... rather than provide a tweakable.
>
>I see that being able to poke those is useful in diagnosing the above ...
>just not sure we want those in mainline. Perhaps we should have 
>CONFIG_TWEAK_EVERYTHING_UP_THE_WAZOO and not enable it in distros,
>or by default. But as an IBM employee, I can assure you IBM would 
>whine mercilessly at the distros until they turned it on, so I'm not 
>sure it helps ;-)
>
>I've been in customer situations dealing with 10 billion tunables before,
>it makes life impossible ;-(
>
>

I agree, FWIW. The *first* barrier to make something tunable in the 
kernel.org
kernel should be a real world(ish) case where current heuristics fall 
down (if
I do this, then setting "blah" to X gives a 200% improvement, wheras if 
I do that,
then X is bad and Y gives a 200% improvement).

The second condition should be that attempts to make the heuristic 
automatically
handle those cases fails or results in too intrusive / complex code.

And I guess thirdly, it should be documented and understandable to 
(usable by)
non kernel hackers.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
