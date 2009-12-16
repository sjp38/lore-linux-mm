Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0C95A6B0062
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 05:28:10 -0500 (EST)
Date: Wed, 16 Dec 2009 11:28:06 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-ID: <20091216102806.GC15031@basil.fritz.box>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com> <20091216101107.GA15031@basil.fritz.box> <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

> > Also the patches didn't fare too well in testing unfortunately.
> > 
> > I suspect we'll rather need multiple locks split per address
> > space range.
> 
> This set doesn't include any changes of the logic. Just replace all mmap_sem.
> I think this is good start point (for introducing another logic etc..)

The problem is that for range locking simple wrapping the locks
in macros is not enough. You need more changes.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
