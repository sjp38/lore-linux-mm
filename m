Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 681126B004D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 09:59:21 -0500 (EST)
Date: Tue, 2 Feb 2010 15:59:11 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202145911.GM4135@random.random>
References: <20100202040145.555474000@alcatraz.americas.sgi.com>
 <20100202080947.GA28736@infradead.org>
 <20100202125943.GH4135@random.random>
 <20100202131341.GI4135@random.random>
 <20100202132919.GO6653@sgi.com>
 <20100202134047.GJ4135@random.random>
 <20100202135141.GH6616@sgi.com>
 <20100202141036.GL4135@random.random>
 <20100202142130.GI6616@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202142130.GI6616@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 08:21:30AM -0600, Robin Holt wrote:
> Your argument seems ridiculous.  Take this larger series of patches which
> touches many parts of the kernel and has a runtime downside for 99% of
> the user community but only when configured on and then try and argue
> with the distros that they should slow all users down for our 1%.

I wasn't suggesting to ask to apply such a patch to a kernel distro!
If that's you understood... That would have been the only ridiculous
thing about it.

If you want to send patches to distro your hack is probably the max as
it alters kABI but not so much.

> > to return -EINVAL I think your userland would also be safer. Only
> 
> I think you missed my correction to an earlier statement.  This patcheset
> does not have any data corruption or userland inconsistency.  I had mistakenly
> spoken of a patchset I am working up as a lesser alternative to this one.

If there is never data corruption or userland inconsistency when I do
mmap(MAP_SHARED) truncate(0) then I've to wonder why at all you need
any modification if you already can handle remote spte invalidation
through atomic sections. That is ridiculous that you can handle it
through atomic-section truncate without sleepability, and you still
ask sleepability for mmu notifier in the first place...

> This is no more a hack than the other long list of compromises that have
> been made in the past.  Very similar to your huge page patchset which
> invalidates a page by using the range callout.  NIHS is not the same as
> a hack.

My hack is just to avoid having to modify mmu notifier API to reduce
the amount of mangling I have to ask people to digest at once, I
simply can't do too many things at once, not right example of
compromise as it's going to get fixed without any downside... no
tradeoff at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
