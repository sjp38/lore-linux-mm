Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 755116B0055
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 06:10:58 -0400 (EDT)
Subject: Re: [RFC/PATCH] mm: Pass virtual address to
 [__]p{te,ud,md}_free_tlb()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090720081054.GH7298@wotan.suse.de>
References: <20090715074952.A36C7DDDB2@ozlabs.org>
	 <20090715135620.GD7298@wotan.suse.de> <1247709255.27937.5.camel@pasglop>
	 <20090720081054.GH7298@wotan.suse.de>
Content-Type: text/plain
Date: Mon, 20 Jul 2009 20:00:41 +1000
Message-Id: <1248084041.30899.7.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Hugh Dickins <hugh@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-07-20 at 10:10 +0200, Nick Piggin wrote:
> 
> Maybe I don't understand your description correctly. The TLB contains
> PMDs, but you say the HW still logically performs another translation
> step using entries in the PMD pages? If I understand that correctly,
> then generic mm does not actually care and would logically fit better
> if those entries were "linux ptes". 

They are :-)

> The pte invalidation routines
> give the virtual address, which you could use to invalidate the TLB.

For PTEs, yes, but not for those PMD entries. IE. I need the virtual
address when destroying PMDs so that I can invalidate those "indirect"
pages. PTEs are already taken care of by existing mechanisms.

Cheers,
Ben.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
