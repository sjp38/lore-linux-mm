Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A0A53900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 12:10:33 -0400 (EDT)
Date: Fri, 15 Apr 2011 18:09:57 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/1] mm: make read-only accessors take const pointer
 parameters
Message-ID: <20110415160957.GV15707@random.random>
References: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com>
 <20110415145133.GO15707@random.random>
 <20110415155916.GD7112@esdhcp04044.research.nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110415155916.GD7112@esdhcp04044.research.nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: akpm@linux-foundation.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 15, 2011 at 06:59:16PM +0300, Phil Carmody wrote:
> of these functions to propagate constness up another layer. It was
> probably in FUSE, as that's the warning at the top of my screen
> currently.

These function themselfs are inline too, so gcc already can see if
memory has been modified inside the inline function, so it shouldn't
provide an advantage. It would provide an advantage if page_count and
friends weren't inline.

> I think gcc itself is smart enough to have already concluded what it 
> can and it will not immediately benefit the build from just this change.

Hmm not sure... but I would hope it is smart enough already with
inline (it should never be worse to inline than encoding the whole
thing by hand in the caller, so skipping the function call
alltogether which then wouldn't require any const).

> I don't think the static analysis tools are as smart as gcc though, by
> any means. GCC actually inlines, so everything is visible to it. The
> static analysis tools only remember the subset of information that they
> think is useful, and apparently 'didn't change anything, even though it 
> could' isn't considered so useful.
> 
> I'm just glad this wasn't an insta-nack, as I am quite a fan of consts,
> and hopefully something can be worked out.

I'm not against it if it's from code strict point of view, I was
mostly trying to understand if this could have any impact, in which
case it wouldn't be false positive. I think it's a false positive if
gcc is as smart as I hope it to be. If we want it from coding style
reasons to keep the code more strict that's fine with me of course.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
