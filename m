Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 53FDE6B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 16:08:52 -0400 (EDT)
Message-ID: <49FB56C3.4030407@redhat.com>
Date: Fri, 01 May 2009 16:08:35 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
References: <20090428044426.GA5035@eskimo.com> <20090430072057.GA4663@eskimo.com> 	<20090430174536.d0f438dd.akpm@linux-foundation.org> <20090430205936.0f8b29fc@riellaptop.surriel.com> 	<20090430181340.6f07421d.akpm@linux-foundation.org> <20090430215034.4748e615@riellaptop.surriel.com> 	<20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com> 	<2c0942db0905011104u4e6df9ap9d95fa30b1284294@mail.gmail.com> 	<49FB4EBB.3030404@redhat.com> <2c0942db0905011244v331273dfr2bb34953e42bebdf@mail.gmail.com>
In-Reply-To: <2c0942db0905011244v331273dfr2bb34953e42bebdf@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, elladan@eskimo.com, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ray Lee wrote:

> Streaming IO should always be at the bottom of the list as it's nearly
> always use-once. That's not the interesting case.

Unfortunately, on current 2.6.28 through 2.6.30 that is broken.

Streaming IO will eventually eat away all of the pages on the
active file list, causing the binaries and libraries that programs
used to be kicked out of memory.

Not interesting?

> The interesting case is an updatedb running in the background, paging
> out firefox, or worse, parts of X. That sucks.

This is a combination of use-once IO and VFS metadata.

The used-once pages can be reclaimed fairly easily.

The growing metadata needs to be addressed by putting pressure
on it via the slab/slub/slob shrinker functions.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
