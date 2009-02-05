Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 789CA6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 16:05:43 -0500 (EST)
Message-ID: <498B54A0.7040005@goop.org>
Date: Thu, 05 Feb 2009 13:05:36 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: pud_bad vs pud_bad
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu> <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu> <Pine.LNX.4.64.0902051921150.30938@blonde.anvils> <498B4F1F.5070306@goop.org> <Pine.LNX.4.64.0902052046240.18431@blonde.anvils>
In-Reply-To: <Pine.LNX.4.64.0902052046240.18431@blonde.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Ingo Molnar <mingo@elte.hu>, William Lee Irwin III <wli@movementarian.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
>> Hardware doesn't allow it.  It will explode (well, trap) if you set anything
>> other than P in the top level.
>>     
>
> Oh, interesting, I'd never realized that.
>   

There are some later extensions to reuse some of the bits for things 
like tlb reload policy (I think; I'd have to check to be sure), so 
they're fairly non-pte-like.

>> By the by, what are the chances we'll be able to deprecate non-PAE 32-bit?
>>     
>
> I sincerely hope 0!  I shed no tears at losing support for NUMAQ,
> but why should we be forced to double all the 32-bit ptes?  You want
> us all to be using NX?  Or you just want to cut your test/edit matrix -
> that I can well understand!
>   

Yes, that's the gist of it.  We could simplify things by having only one 
pte format and only have to parameterise with 3/4 level pagetables.  
We'd lose support for non-PAE cpus, including the first Pentium M (which 
is probably still in fairly wide use, unfortunately).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
