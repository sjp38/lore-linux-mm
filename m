Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0786B013C
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 20:53:34 -0400 (EDT)
Subject: Re: [RFC/PATCH] mm: Pass virtual address to
 [__]p{te,ud,md}_free_tlb()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.2.01.0907220930320.19335@localhost.localdomain>
References: <20090715074952.A36C7DDDB2@ozlabs.org>
	 <20090715135620.GD7298@wotan.suse.de> <1248073873.13067.31.camel@pasglop>
	 <alpine.LFD.2.01.0907220930320.19335@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 23 Jul 2009 10:53:35 +1000
Message-Id: <1248310415.3367.22.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Hugh Dickins <hugh@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-07-22 at 09:31 -0700, Linus Torvalds wrote:
> > CC'ing Linus here. How do you want to proceed with that merge ? (IE. so
> > far nobody objected to the patch itself)
> 
> Maybe you can put it as a separate branch in -next, and have it merged 
> before the stuff that depends on it, and then just sending it to me (as a 
> git branch or patch or whatever) in the first day of the merge window?

Hrm... my powerpc-next branch will contain stuff that depend on it, so
I'll probably have to pull it in though, unless I tell all my
sub-maintainers to also pull from that other branch first :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
