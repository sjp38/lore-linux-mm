Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 10B8C900149
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 11:16:42 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 00/11] IO-less dirty throttling v12
References: <20111003134228.090592370@intel.com>
	<20111004195206.GG28306@redhat.com>
Date: Wed, 05 Oct 2011 08:16:41 -0700
In-Reply-To: <20111004195206.GG28306@redhat.com> (Vivek Goyal's message of
	"Tue, 4 Oct 2011 15:52:06 -0400")
Message-ID: <m2ipo34gfa.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Vivek Goyal <vgoyal@redhat.com> writes:
>
> Will it make sense to break down this work in two patch series. First
> push IO less balance dirty pages and then all the complicated pieces
> of ratelimits.

I would be wary against too much refactoring of well tested patchkits.
I've seen too many cases where this can add nasty and subtle bugs,
given that our unit test coverage is usually relatively poor.

For example the infamous "absolute path names became twice as slow" 
bug was very likely introduced in such a refactoring of a large VFS
patchkit.

While it's generally good to make things easier for reviewers too much
of a good thing can be quite bad.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
