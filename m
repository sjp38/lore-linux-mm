Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5436B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:23:13 -0500 (EST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 1/8] block: limit default readahead size for small devices
References: <20111121091819.394895091@intel.com>
	<20111121093846.121502745@intel.com>
	<20111121145247.0e37dc36.akpm@linux-foundation.org>
Date: Tue, 22 Nov 2011 09:23:05 -0500
In-Reply-To: <20111121145247.0e37dc36.akpm@linux-foundation.org> (Andrew
	Morton's message of "Mon, 21 Nov 2011 14:52:47 -0800")
Message-ID: <x49wras44om.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Li Shaohua <shaohua.li@intel.com>, Clemens Ladisch <clemens@ladisch.de>, Jens Axboe <jens.axboe@oracle.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> In a better world, userspace would run a
> work-out-what-readahead-size-to-use script each time a distro is
> installed and when new storage devices are added/detected.  Userspace
> would then remember that readahead size for subsequent bootups.

I'd be interested to hear what factors you think should be taken into
account by such a script.  I agree that there are certain things, like
timing of reads of different sizes, or heuristics based on the size of
installed memory, which could contribute to the default readahead size.
However, other things, like memory pressure while running the desired
workload, can't really be measured by an installer or one-time script.

> In the real world, we shovel guaranteed-to-be-wrong guesswork into the
> kernel and everyone just uses the results.  Sigh.

I'm not sure a userspace tool is the panacea you paint.  However, if you
can provide some guidance on what you think could make things better,
I'm happy to give it a go.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
