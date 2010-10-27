Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8B26B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 04:19:09 -0400 (EDT)
Date: Wed, 27 Oct 2010 10:18:53 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] Please pull hwpoison updates for 2.6.37
Message-ID: <20101027081853.GA20196@elte.hu>
References: <20101026100923.GA5118@basil.fritz.box>
 <20101027074254.GA809@elte.hu>
 <20101027075846.GA2472@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101027075846.GA2472@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, x86@kernel.org
List-ID: <linux-mm.kvack.org>


* Andi Kleen <andi@firstfloor.org> wrote:

> * Ingo Molnar <mingo@elte.hu> wrote:
>
> > 
> > * Andi Kleen <andi@firstfloor.org> wrote:
> >
> > > [...]
> > >
> > > - x86 hwpoison signal reporting fix. I tried to get an ack for that,
> > >   but wasn't able to motivate the x86 maintainers to reply to their emails.
> > 
> > Hm, you sent it once two weeks before the merge window and we missed that.
> > 
> > Patch looks ok. (I'd personally not expose an #ifdef in the middle of a function 
> > like that but that's a detail that doesnt affect correctness.)
> > 
> > Thanks,
> 
> Thanks for the review.

You are welcome! How about the cleanliness feedback that i gave?
(the stuff in parentheses)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
