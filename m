Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA956B002D
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 20:52:00 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2897F3EE0C0
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 09:51:57 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E61C745DE56
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 09:51:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CA8C845DE50
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 09:51:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B82541DB8045
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 09:51:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E0511DB803E
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 09:51:56 +0900 (JST)
Date: Tue, 1 Nov 2011 09:50:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-Id: <20111101095038.30289914.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <ef778e79-72d0-4c58-99e8-3b36d85fa30d@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default
 20111031171321.097a166c.kamezawa.hiroyu@jp.fujitsu.com>
	<ef778e79-72d0-4c58-99e8-3b36d85fa30d@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

On Mon, 31 Oct 2011 09:38:12 -0700 (PDT)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> > From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> > Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
> 
> Hi Kame --
> 
> Thanks for your reply and for your earlier reviews of frontswap,
> and my apologies that I accidentally left you off of the Cc list \
> for the basenote of this git-pull request.
> 
> > I don't have heavy concerns to the codes itself but this process as bypassing -mm
> > or linux-next seems ugly.
> 
> First, frontswap IS in linux-next and it has been since June 3
> and v11 has been in linux-next since September 23.  This
> is stated in the base git-pull request.
>  

Ok, I'm sorry. I found frontswap.c in my tree.


> > Why bypass -mm tree ?
> > 
> > I think you planned to merge this via -mm tree and, then, posted patches
> > to linux-mm with CC -mm guys.
> 
> Hmmm... the mm process is not clear or well-documented.

not complicated to me.

post -> akpm's -mm tree -> mainline.

But your tree seems to be in -mm via linux-next. Hmm, complicated ;(
I'm sorry I didn't notice frontswap.c was there....


> > I think you posted 2011/09/16 at the last time, v10. But no further submission
> > to gather acks/reviews from Mel, Johannes, Andrew, Hugh etc.. and no inclusion
> > request to -mm or -next. _AND_, IIUC, at v10, the number of posted pathces was 6.
> > Why now 8 ? Just because it's simple changes ?
> 
> See https://lkml.org/lkml/2011/9/21/373.  Konrad Wilk
> helped me to reorganize the patches (closer to what you
> suggested I think), but there were no code changes between
> v10 and v11, just dividing up the patches differently
> as Konrad thought there should be more smaller commits.
> So no code change between v10 and v11 but the number of
> patches went from 6 to 8.
> 
> My last line in that post should also make it clear that
> I thought I was done and ready for the 3.2 window, so there
> was no evil intent on my part to subvert a process.
> It would have been nice if someone had told me there
> were uncompleted steps in the -mm process or, even better,
> pointed me to a (non-existent?) document where I could see
> for myself if I was missing steps!
> 
> So... now what?
> 

As far as I know, patches for memory management should go through akpm's tree.
And most of developpers in that area see that tree.
Now, your tree goes through linux-next. It complicates the problem.

When a patch goes through -mm tree, its justification is already checked by
, at least, akpm. And while in -mm tree, other developpers checks it and
some improvements are done there.

Now, you tries to push patches via linux-next and your
justification for patches is checked _now_. That's what happens.
It's not complicated. I think other linux-next patches are checked
its justification at pull request.

So, all your work will be to convice people that this feature is
necessary and not-intrusive, here. 

>From my point of view,

  - I have no concerns with performance cost. But, at the same time,
    I want to see performance improvement numbers. 

  - At discussing an fujitsu user support guy (just now), he asked
    'why it's not designed as device driver ?"
    I couldn't answered. 
 
    So, I have small concerns with frontswap.ops ABI design.
    Do we need ABI and other modules should be pluggable ?
    Can frontswap be implemented as something like

    # setup frontswap via device-mapper or some.
    # swapon /dev/frontswap 
    ?
    It seems required hooks are just before/after read/write swap device.
    other hooks can be implemented in notifier..no ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
