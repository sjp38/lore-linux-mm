Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8716B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 16:51:00 -0500 (EST)
Date: Thu, 5 Feb 2009 22:50:50 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pud_bad vs pud_bad
Message-ID: <20090205215050.GB28097@elte.hu>
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu> <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu> <Pine.LNX.4.64.0902051921150.30938@blonde.anvils> <498B4F1F.5070306@goop.org> <Pine.LNX.4.64.0902052046240.18431@blonde.anvils> <498B54A0.7040005@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <498B54A0.7040005@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Hugh Dickins <hugh@veritas.com>, William Lee Irwin III <wli@movementarian.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Jeremy Fitzhardinge <jeremy@goop.org> wrote:

>> I sincerely hope 0!  I shed no tears at losing support for NUMAQ, but why 
>> should we be forced to double all the 32-bit ptes?  You want us all to be 
>> using NX?  Or you just want to cut your test/edit matrix - that I can 
>> well understand!
>
> Yes, that's the gist of it.  We could simplify things by having only one 
> pte format and only have to parameterise with 3/4 level pagetables.  We'd 
> lose support for non-PAE cpus, including the first Pentium M (which is 
> probably still in fairly wide use, unfortunately).

We'd also lose a fair bit of performance (not to mention the pagetable 
footprint doubling that Hugh already mentioned) on 32-bit PAE capable 
systems that dont actually have RAM above 4G physical.

Bad idea really ...

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
