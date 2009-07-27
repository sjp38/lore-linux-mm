Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 409576B004D
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 17:35:43 -0400 (EDT)
Subject: Re: [RFC/PATCH] mm: Pass virtual address to
 [__]p{te,ud,md}_free_tlb()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.2.01.0907271210210.25224@localhost.localdomain>
References: <20090715074952.A36C7DDDB2@ozlabs.org>
	 <20090715135620.GD7298@wotan.suse.de> <1248073873.13067.31.camel@pasglop>
	 <alpine.LFD.2.01.0907220930320.19335@localhost.localdomain>
	 <1248310415.3367.22.camel@pasglop>
	 <alpine.LFD.2.01.0907271210210.25224@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 28 Jul 2009 07:35:35 +1000
Message-Id: <1248730535.23358.1.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Hugh Dickins <hugh@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-07-27 at 12:11 -0700, Linus Torvalds wrote:
> 
> On Thu, 23 Jul 2009, Benjamin Herrenschmidt wrote:
> > 
> > Hrm... my powerpc-next branch will contain stuff that depend on it, so
> > I'll probably have to pull it in though, unless I tell all my
> > sub-maintainers to also pull from that other branch first :-)
> 
> Ok, I'll just apply the patch. It does look obvious enough.

Thanks. It's been in -next for a day now btw, and afaik, there have been
no issue reported.

Cheers,
Ben.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
