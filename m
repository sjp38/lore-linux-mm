Received: by wproxy.gmail.com with SMTP id 49so1568wri
        for <linux-mm@kvack.org>; Tue, 29 Mar 2005 01:10:06 -0800 (PST)
Message-ID: <2c1942a7050329011017d2f964@mail.gmail.com>
Date: Tue, 29 Mar 2005 12:10:05 +0300
From: Levent Serinol <lserinol@gmail.com>
Reply-To: Levent Serinol <lserinol@gmail.com>
Subject: Re: [RFC][PATCH] tunable zone watermarks
In-Reply-To: <4248BCFD.80909@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
References: <2c1942a70503272243c351eee@mail.gmail.com>
	 <160420000.1112038232@flay> <20050328195143.GJ29310@logos.cnet>
	 <183780000.1112057143@flay> <4248BCFD.80909@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Tue, 29 Mar 2005 12:27:09 +1000, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Martin J. Bligh wrote:
> 
> >>On Mon, Mar 28, 2005 at 11:30:32AM -0800, Martin J. Bligh wrote:
> >>
> >>>What situations do you want to tune them in? Would be nicer to do this
> >>>automagically ...
> >>>
> >>We do it automagically right now. What do you mean?
> >>
> >>It is useful for testing purpose - but then you need an understanding of
> >>MM internals to make good use of it.
> >>
> >>The only tweak available now is lowmem_reserve.
> >>
> >>
> 
> min_free_kbytes is closer to what you want (sorry if it has already
> been mentioned).


 Yes, closer but has a fixed ratio between min,low,high limits. For
example if you like to kick kswapd earlier and let it to make more
work, you have no chance with min_free_kbytes. You can only kick
kswapd earlier but  you cannot tell it to free how much  pages you
want due to fixed ratio. Therefore, tuning zone watermarks makes it
more customizable.
Also, as Mr Tosatti mentioned you can use this tunables for debugging.

Also, as you know  There're many tunable things in kernel that can
vanish your system If you don't know what u're doing ;-)

For example on Solaris, you have an option to tell mm how much memory
you want it to try to free (desfree). It's default value is lotsfree /
2, but you have such an option to define desfree besides it default
value. with min_free_kbytes you don't have such an option :-(

Documentation is no problem. But if you still think that, this
tunables are very dangerous it
can go into CONFIG_DEBUG_KERNEL stuff.


> 
> >>I'm sure there are loads where the default watermark values are
> >>not optimal.
> >>
> >
> >Yeah, I'm just not at all convinced that the solution to these problems
> >is to make everything tunable up the wazoo ... all that seems to do is
> >
> >1) Encourage customers to break their systems in new and interesting ways
> >2) Line the pockets of "tuning consultants".
> >
> >If there are loads where the default watermark values are not optimal
> >(and I agree there probably are) then what we really need is to auto
> >recognise those, and fix them in the OS ... rather than provide a tweakable.
> >
> >I see that being able to poke those is useful in diagnosing the above ...
> >just not sure we want those in mainline. Perhaps we should have
> >CONFIG_TWEAK_EVERYTHING_UP_THE_WAZOO and not enable it in distros,
> >or by default. But as an IBM employee, I can assure you IBM would
> >whine mercilessly at the distros until they turned it on, so I'm not
> >sure it helps ;-)
> >
> >I've been in customer situations dealing with 10 billion tunables before,
> >it makes life impossible ;-(
> >
> >
> 
> I agree, FWIW. The *first* barrier to make something tunable in the
> kernel.org
> kernel should be a real world(ish) case where current heuristics fall
> down (if
> I do this, then setting "blah" to X gives a 200% improvement, wheras if
> I do that,
> then X is bad and Y gives a 200% improvement).
> 
> The second condition should be that attempts to make the heuristic
> automatically
> handle those cases fails or results in too intrusive / complex code.
> 
> And I guess thirdly, it should be documented and understandable to
> (usable by)
> non kernel hackers.
> 
> 


-- 

Stay out of the road, if you want to grow old. 
~ Pink Floyd ~.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
