Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 28EA26B0047
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 15:57:42 -0500 (EST)
Date: Thu, 5 Feb 2009 21:57:35 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pud_bad vs pud_bad
Message-ID: <20090205205735.GA21500@elte.hu>
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu> <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu> <Pine.LNX.4.64.0902051921150.30938@blonde.anvils> <498B4F1F.5070306@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <498B4F1F.5070306@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Hugh Dickins <hugh@veritas.com>, William Lee Irwin III <wli@movementarian.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Hugh Dickins wrote:
>> However... I forget how the folding works out.  The pgd in the 32-bit
>> PAE case used to have just the pfn and the present bit set in that
>> little array of four entries: if pud_bad() ends up getting applied
>> to that, I guess it will blow up.
>>   
>
> Ah, that's a good point.
>
>> If so, my preferred answer would actually be to make those 4 entries
>> look more like real ptes; but you may think I'm being a bit silly.
>
> Hardware doesn't allow it.  It will explode (well, trap) if you set  
> anything other than P in the top level.

Yeah. I was the first Linux hacker in history to put a x86 CPU into PAE mode 
under Linux 10+ years ago, and i can attest to the 'explodes way too easily' 
aspect quite emphatically ;-) Took me 3-4 days to bootstrap it.

> By the by, what are the chances we'll be able to deprecate non-PAE 32-bit?

For the next 10 years: pretty much zero.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
