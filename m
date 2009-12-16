Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB476B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 06:32:03 -0500 (EST)
Date: Wed, 16 Dec 2009 12:31:58 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-ID: <20091216113158.GE15031@basil.fritz.box>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com> <20091216101107.GA15031@basil.fritz.box> <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com> <20091216102806.GC15031@basil.fritz.box> <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com> <20091216104951.GD15031@basil.fritz.box> <20091216201218.42ff7f05.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091216201218.42ff7f05.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, Dec 16, 2009 at 08:12:18PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 16 Dec 2009 11:49:51 +0100
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > On Wed, Dec 16, 2009 at 07:31:09PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Wed, 16 Dec 2009 11:28:06 +0100
> > > Andi Kleen <andi@firstfloor.org> wrote:
> > > 
> > > > > > Also the patches didn't fare too well in testing unfortunately.
> > > > > > 
> > > > > > I suspect we'll rather need multiple locks split per address
> > > > > > space range.
> > > > > 
> > > > > This set doesn't include any changes of the logic. Just replace all mmap_sem.
> > > > > I think this is good start point (for introducing another logic etc..)
> > > > 
> > > > The problem is that for range locking simple wrapping the locks
> > > > in macros is not enough. You need more changes.
> > > > 
> > > maybe. but removing scatterred mmap_sem from codes is the first thing to do.
> > > I think this removing itself will take 3 month or a half year.
> > > (So, I didn't remove mmap_sem and leave it as it is.)
> > 
> > I suspect you would just need to change them again then.
> > 
> Do you have alternative recommendation rather than wrapping all accesses by
> special functions ?

Work out what changes need to be done for ranged mmap locks and do them all
in one pass.

Unfortunately I don't know yet either how exactly these changes look 
like, figuring that out is the hard work part in it.

I suspect it would need changing of the common vma list walk loop
pattern.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
