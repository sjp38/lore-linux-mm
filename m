Date: Sat, 28 Aug 2004 09:43:29 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: refill_inactive_zone question
Message-ID: <89340000.1093711408@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.44.0408281651270.2117-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0408281651270.2117-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

--Hugh Dickins <hugh@veritas.com> wrote (on Saturday, August 28, 2004 17:08:23 +0100):

> On Fri, 27 Aug 2004, Marcelo Tosatti wrote:
>> 
>> Oh thanks! I see that. So you just dropped the bit spinlocked and changed
>> mapcount to an atomic variable, right?
> 
> That's it, yes.  It needed a little more rework than that
> (see ChangeLog) but that's the main thrust.
> 
>> Cool. Do you have any numbers on big SMP systems for that change? 
> 
> Sorry, no.  When I sent out the patches a second time to Andrew (didn't
> copy LKML since nothing really changed from the first time in July),
> I did CC Martin in the hope that he might feel the urge to run up
> some numbers (or at least let him be aware of that change lest he
> misinterpret numbers), but I think he was busy with other stuff.

The lab was down for rewiring, and then I forgot about it - sorry. 
Can you resend me the patch again, and I'll get off my ass and do 
something about it? ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
