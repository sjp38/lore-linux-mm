Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 90BD16B01AC
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 04:17:05 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/3] writeback: tracking subsystems causing writeback
References: <1276907415-504-1-git-send-email-mrubin@google.com>
	<1276907415-504-4-git-send-email-mrubin@google.com>
Date: Sat, 19 Jun 2010 10:17:01 +0200
In-Reply-To: <1276907415-504-4-git-send-email-mrubin@google.com> (Michael
	Rubin's message of "Fri, 18 Jun 2010 17:30:15 -0700")
Message-ID: <878w6bphc2.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

Michael Rubin <mrubin@google.com> writes:
>
>     # cat /sys/block/sda/bdi/writeback_stats
>     balance dirty pages                       0
>     balance dirty pages waiting               0
>     periodic writeback                    92024
>     periodic writeback exited                 0
>     laptop periodic                           0
>     laptop or bg threshold                    0
>     free more memory                          0
>     try to free pages                       271
>     syc_sync                                  6
>     sync filesystem                           0

That exports a lot of kernel internals in /sys, presumably read by some
applications. What happens with the applications if the kernel internals
ever change?  Will the application break?

It would be bad to not be able to change the kernel because of
such an interface.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
