Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7FECE600429
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 22:30:15 -0400 (EDT)
Date: Mon, 2 Aug 2010 10:30:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/6] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-ID: <20100802023008.GA13035@localhost>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
 <1280497020-22816-7-git-send-email-mel@csn.ul.ie>
 <20100730150601.199c5618.akpm@linux-foundation.org>
 <20100801115640.GA18943@localhost>
 <20100801130300.GA19523@localhost>
 <80868B70-B17D-4007-AA15-5C11F0F95353@xyke.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80868B70-B17D-4007-AA15-5C11F0F95353@xyke.com>
Sender: owner-linux-mm@kvack.org
To: Sean Jensen-Grey <seanj@xyke.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, pvz@pvz.pp.se, bgamari@gmail.com, larppaxyz@gmail.com, kernel-bugs.dev1world@spamgourmet.com, akatopaz@gmail.com, frankrq2009@gmx.com, thomas.pi@arcor.de, spawels13@gmail.com, vshader@gmail.com, rockorequin@hotmail.com, ylalym@gmail.com, theholyettlz@googlemail.com, hassium@yandex.ru
List-ID: <linux-mm.kvack.org>

Hi Sean,

On Mon, Aug 02, 2010 at 10:17:27AM +0800, Sean Jensen-Grey wrote:
> Wu,
> 
> Thank you for doing this. This still bites me on a weekly basis. I don't have much time to test the patches this week, but I should get access to an identical box week after next.

That's OK.

> BTW, I experience the issues even with 8-10GB of free ram. I have 12GB currently.

Thanks for the important information. It means the patches proposed
are not likely to help your case.

In Comment #47 for bug 12309, your kernel 2.6.27 is too old though.  You may
well benefit from Jens' CFQ low latency improvements if switching to a recent
kernel.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
