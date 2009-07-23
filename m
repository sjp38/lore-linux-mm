Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7546B013E
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 20:59:13 -0400 (EDT)
Message-Id: <74BA64FD-0DFF-45A2-868D-A001D9BA496F@kernel.crashing.org>
From: Kumar Gala <galak@kernel.crashing.org>
In-Reply-To: <1248310415.3367.22.camel@pasglop>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Apple Message framework v935.3)
Subject: Re: [RFC/PATCH] mm: Pass virtual address to [__]p{te,ud,md}_free_tlb()
Date: Wed, 22 Jul 2009 19:59:08 -0500
References: <20090715074952.A36C7DDDB2@ozlabs.org> <20090715135620.GD7298@wotan.suse.de> <1248073873.13067.31.camel@pasglop> <alpine.LFD.2.01.0907220930320.19335@localhost.localdomain> <1248310415.3367.22.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux-Arch <linux-arch@vger.kernel.org>, linuxppc-dev@ozlabs.org, Hugh Dickins <hugh@tiscali.co.uk>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Jul 22, 2009, at 7:53 PM, Benjamin Herrenschmidt wrote:

> On Wed, 2009-07-22 at 09:31 -0700, Linus Torvalds wrote:
>>> CC'ing Linus here. How do you want to proceed with that merge ?  
>>> (IE. so
>>> far nobody objected to the patch itself)
>>
>> Maybe you can put it as a separate branch in -next, and have it  
>> merged
>> before the stuff that depends on it, and then just sending it to me  
>> (as a
>> git branch or patch or whatever) in the first day of the merge  
>> window?
>
> Hrm... my powerpc-next branch will contain stuff that depend on it, so
> I'll probably have to pull it in though, unless I tell all my
> sub-maintainers to also pull from that other branch first :-)

Can you not cherry pick it into powerpc-next to 'pull it through'?

- k

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
