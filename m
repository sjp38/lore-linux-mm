Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF906B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 15:52:28 -0500 (EST)
Date: Thu, 5 Feb 2009 20:51:40 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: pud_bad vs pud_bad
In-Reply-To: <498B4F1F.5070306@goop.org>
Message-ID: <Pine.LNX.4.64.0902052046240.18431@blonde.anvils>
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu>
 <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu>
 <Pine.LNX.4.64.0902051921150.30938@blonde.anvils> <498B4F1F.5070306@goop.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Ingo Molnar <mingo@elte.hu>, William Lee Irwin III <wli@movementarian.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Feb 2009, Jeremy Fitzhardinge wrote:
> Hugh Dickins wrote:
> > However... I forget how the folding works out.  The pgd in the 32-bit
> > PAE case used to have just the pfn and the present bit set in that
> > little array of four entries: if pud_bad() ends up getting applied
> > to that, I guess it will blow up.
> 
> Ah, that's a good point.
> 
> > If so, my preferred answer would actually be to make those 4 entries
> > look more like real ptes; but you may think I'm being a bit silly.
> 
> Hardware doesn't allow it.  It will explode (well, trap) if you set anything
> other than P in the top level.

Oh, interesting, I'd never realized that.

> By the by, what are the chances we'll be able to deprecate non-PAE 32-bit?

I sincerely hope 0!  I shed no tears at losing support for NUMAQ,
but why should we be forced to double all the 32-bit ptes?  You want
us all to be using NX?  Or you just want to cut your test/edit matrix -
that I can well understand!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
