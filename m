Message-ID: <48DC106D.9010601@goop.org>
Date: Thu, 25 Sep 2008 15:27:57 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: PTE access rules & abstraction
References: <1221846139.8077.25.camel@pasglop>  <48D739B2.1050202@goop.org>	 <1222117551.12085.39.camel@pasglop>	 <Pine.LNX.4.64.0809241919520.575@blonde.site>	 <1222291248.8277.90.camel@pasglop>	 <Pine.LNX.4.64.0809250049270.21674@blonde.site>	 <1222304686.8277.136.camel@pasglop>  <48DBD532.80607@goop.org> <1222379063.8277.202.camel@pasglop>
In-Reply-To: <1222379063.8277.202.camel@pasglop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> On Thu, 2008-09-25 at 11:15 -0700, Jeremy Fitzhardinge wrote:
>   
>> The ptep_modify_prot_start/commit pair specifies a single pte update in
>> such a way to allow more implementation flexibility - ie, there's no
>> naked requirement for an atomic fetch-and-clear operation.  I chose the
>> transaction-like terminology to emphasize that the start/commit
>> functions must be strictly paired; there's no way to fail or abort the
>> "transaction".  A whole group of those start/commit pairs can be batched
>> together without affecting their semantics.
>>     
>
> I still can't see the point of having now 3 functions instead of just
> one such as ptep_modify_protection(). I don't see what it buys you other
> than adding gratuituous new interfaces.
>   

Yeah, that would work too; that's pretty much how Xen implements it
anyway.  The main advantage of the start/commit pair is that the
resulting code was completely unchanged from the old code.  The mprotect
sequence using ptep_modify_protection would end up reading the pte twice
before writing it.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
