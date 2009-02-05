Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 618AC6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 15:13:26 -0500 (EST)
Date: Thu, 5 Feb 2009 20:12:44 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: pud_bad vs pud_bad
In-Reply-To: <20090205194932.GB3129@elte.hu>
Message-ID: <Pine.LNX.4.64.0902052004550.12955@blonde.anvils>
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu>
 <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu>
 <Pine.LNX.4.64.0902051921150.30938@blonde.anvils> <20090205194932.GB3129@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, William Lee Irwin III <wli@movementarian.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Feb 2009, Ingo Molnar wrote:
> * Hugh Dickins <hugh@veritas.com> wrote:
> > 
> > Simpler and more compact, but not as strict: in particular, a value of
> > 0 or 1 is identified as bad by that 64-bit test, but not by the 32-bit.
> 
> yes, indeed you are right - the 64-bit test does not allow the KERNPG_TABLE 
> bits to go zero.
> 
> Those are the present, rw, accessed and dirty bits. Do they really matter 
> that much? If a toplevel entry goes !present or readonly, we notice that 
> _fast_, without any checks. If it goes !access or !dirty - does that matter?

I've not given it a great deal of thought, why this or that bit.
These p??_bad checks originate from 2.4 or earlier, and by mistake
got weakened somewhere along the way, and last time it was discussed
we agreed to strenghthen them (and IIRC Jeremy himself did so).

> 
> These checks are done all the time, and even a single instruction can count. 
> The bits that are checked are enough to notice random memory corruption.

Well, I am surprised that you would be arguing for weakening such
a very simple check.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
