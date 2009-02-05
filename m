Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6A25B6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 16:09:46 -0500 (EST)
Date: Thu, 5 Feb 2009 21:09:04 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: pud_bad vs pud_bad
In-Reply-To: <20090205205606.GG10229@movementarian.org>
Message-ID: <Pine.LNX.4.64.0902052103080.20627@blonde.anvils>
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu>
 <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu>
 <Pine.LNX.4.64.0902051921150.30938@blonde.anvils> <20090205194932.GB3129@elte.hu>
 <20090205195817.GF10229@movementarian.org> <Pine.LNX.4.64.0902052013230.12955@blonde.anvils>
 <20090205205606.GG10229@movementarian.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: wli@movementarian.org
Cc: Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Feb 2009, wli@movementarian.org wrote:
> On Thu, 5 Feb 2009, wli@movementarian.org wrote:
> >> The RW bit needs to be allowed to become read-only for hugetlb COW.
> >> Changing it over to the 32-bit method is a bugfix by that token.
> 
> On Thu, Feb 05, 2009 at 08:14:42PM +0000, Hugh Dickins wrote:
> > If there's a bugfix to be made there, of course I'm in favour:
> > but how come we've never seen such a bug?  hugetlb COW has been
> > around for a year or two by now, hasn't it?
> 
> We can tell from the code that a write-protected pte mapping of a
> 1GB hugetlb page would be flagged as bad. It must not be called on
> ptes mapping hugetlb pages if they're not getting flagged.

Ah, I see what you mean now.  Yes, the hugetlb case goes its own way
and doesn't normally hit those p??_bad() macro/inlines; but we got
caught out in follow_page() a year ago, a bad looked huge or a
huge looked bad, but I forget the details at this instant.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
