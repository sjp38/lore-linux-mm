Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE616B00DF
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 15:41:51 -0400 (EDT)
From: pageexec@freemail.hu
Date: Wed, 03 Jun 2009 21:41:35 +0200
MIME-Version: 1.0
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change ZERO_SIZE_PTR to point at unmapped space)
Reply-to: pageexec@freemail.hu
Message-ID: <4A26D1EF.21895.2E070251@pageexec.freemail.hu>
In-reply-to: <alpine.LFD.2.01.0906031142390.4880@localhost.localdomain>
References: <20090530230022.GO6535@oblivion.subreption.com>, <20090603183939.GC18561@oblivion.subreption.com>, <alpine.LFD.2.01.0906031142390.4880@localhost.localdomain>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 3 Jun 2009 at 11:45, Linus Torvalds wrote:

> 
> 
> On Wed, 3 Jun 2009, Larry H. wrote:
> > > 
> > > The fact, the NULL pointer attack is neither easy nor common. It's 
> > > perfectly reasonable to say "we'll allow mmap at virtual address zero".
> > 
> > And how could you calibrate if this attack venue isn't easy to take
> > advantage of? Or not commonly abused? What empirical results led you to this
> > conclusion?
> 
> It's not a primary attack vector. You need to have already broken local 
> security to get there - you need to be able to execute code.

during last summer's flame war^W^Wdiscussion about how you guys were covering
up security fixes you brought an example of smart university students breaking
communal boxes left and right. are you now saying that it was actually a strawman
argument as you consider that situation already broken? you can't have it both
ways ;).

> That means that you've already by-passed all the main security. It's thus 
> by definition less common than attack vectors like buffer overflows that 
> give you that capability in the first place.

that only means that you've ignored multi-user boxes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
