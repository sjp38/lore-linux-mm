Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E15276B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 19:40:08 -0400 (EDT)
Date: Mon, 23 May 2011 17:40:04 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: (Short?) merge window reminder
Message-ID: <20110523234003.GC26392@parisc-linux.org>
References: <BANLkTi=PLuZhx1=rCfOtg=aOTuC1UbuPYg@mail.gmail.com> <20110523192056.GC23629@elte.hu> <BANLkTikdgM+kSvaEYuQkgCYJZELnvwfetg@mail.gmail.com> <20110523222121.GD12777@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110523222121.GD12777@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, May 23, 2011 at 03:21:21PM -0700, Greg KH wrote:
> On Mon, May 23, 2011 at 01:33:48PM -0700, Linus Torvalds wrote:
> > On Mon, May 23, 2011 at 12:20 PM, Ingo Molnar <mingo@elte.hu> wrote:
> > > I really hope there's also a voice that tells you to wait until .42 before
> > > cutting 3.0.0! :-)
> > 
> > So I'm toying with 3.0 (and in that case, it really would be "3.0",
> > not "3.0.0" - the stable team would get the third digit rather than
> > the fourth one.
> 
> I like that, it would make things much easier for me to keep track of
> stuff.

As long as 3.14 turns into a long-term support kernel and gets up to 159 ...

In all serious, I'm very supportive of this move.  I'm heartily sick
of people claiming "we have version 2.6 support" when they really mean
they haven't updated since version 2.6.9.  Yeah, congratulations, you're
seven years out of date.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
