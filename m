Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7556B004F
	for <linux-mm@kvack.org>; Sun, 31 May 2009 08:14:49 -0400 (EDT)
Date: Sun, 31 May 2009 05:16:36 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090531121636.GC10598@oblivion.subreption.com>
References: <20090530082048.GM29711@oblivion.subreption.com> <20090530173428.GA20013@elte.hu> <20090530180333.GH6535@oblivion.subreption.com> <20090530182113.GA25237@elte.hu> <20090530184534.GJ6535@oblivion.subreption.com> <20090530190828.GA31199@elte.hu> <4A21999E.5050606@redhat.com> <84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com> <20090531001052.40ac57d2@lxorguk.ukuu.org.uk> <84144f020905302314w12c4c7f8jc8241e36c847f53e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020905302314w12c4c7f8jc8241e36c847f53e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 09:14 Sun 31 May     , Pekka Enberg wrote:
> Hi Alan,
> 
> On Sun, May 31, 2009 at 2:10 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> >> It's pretty damn obvious that Larry's patches have a much bigger
> >> performance impact than using kzfree() for selected parts of the
> >> kernel. So yes, I do expect him to benchmark and demonstrate that
> >> kzfree() has _performance problems_ before we can look into merging
> >> his patches.
> >
> > We seem to be muddling up multiple things here which is not helpful.
> 
> Yup.
> 
> On Sun, May 31, 2009 at 2:10 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > There are three things going on
> >
> > #1 Is ksize() buggy ?
> 
> No, there's nothing wrong with ksize() I am aware of. Yes, Larry has
> been saying it is but hasn't provided any evidence so far.

Excuse me, do you have an attention or reading disorder? Compound pages
and SLOB anyone? Duplication of test branches for pointer validation?

What are you trying to accomplish by claiming I've never provided
information which I sent to a public channel (this list)? You realize
someone who really cares can just navigate through the cesspool of
messages this thread became, and see the ones where I'm actually trying
to explain the situation to you?

It's amusing that at the expense of your egos, kernel security is ten years
lagging behind for Linux. And it's all to your (and well known others') credit.
Congratulations, and thank you for keeping it that way.

> On Sun, May 31, 2009 at 2:10 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > #2 Using kzfree() to clear specific bits of memory (and I question the
> > kzfree implementation as it seems ksize can return numbers much much
> > bigger than the allocated space you need to clear - correct but oversize)
> > or using other flags. I'd favour kzfree personally (and fixing it to work
> > properly)
> 
> Well, yes, that's what kzfree() needs to do given the current API. I
> am not sure why you think it's a problem, though. Adding a size
> argument to the function will make it more error prone.

ksize is not designed to be used extensively at all. It's not the
intention of that API.

You should be implementing kzfree_skb and so forth. Just make sure the
definitions stay in header files I can ifdef 0 away when I patch my
kernel at the commodity of my own home, and use a solution which isn't
broken (or PaX itself). Removing all these calls will be quite a burden.

> On Sun, May 31, 2009 at 2:10 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > #3 People wanting to be able to select for more security *irrespective*
> > of performance cost. Which is no different to SELinux for example.
> 
> Yeah, as I said before, I really don't have any objections to this. I
> just think nobody is going to enable it so memset() or kzfree() in
> relevant places is probably a good idea.

Fallacy man cometh! Let's assume everyone has the same exact lacking and
irresponsible security requirements you have, and try to make it look
like it's the real world. I know you are not alone there.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
