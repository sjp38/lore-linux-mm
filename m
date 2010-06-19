Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 152156B0071
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 16:23:47 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/3] writeback: tracking subsystems causing writeback
References: <1276907415-504-1-git-send-email-mrubin@google.com>
	<1276907415-504-4-git-send-email-mrubin@google.com>
	<878w6bphc2.fsf@basil.nowhere.org>
	<AANLkTimhsQdLV7UeMppz8mwzQPUfDQbvdNdOCiVnxdKM@mail.gmail.com>
Date: Sat, 19 Jun 2010 22:23:48 +0200
In-Reply-To: <AANLkTimhsQdLV7UeMppz8mwzQPUfDQbvdNdOCiVnxdKM@mail.gmail.com>
	(Michael Rubin's message of "Sat, 19 Jun 2010 10:49:34 -0700")
Message-ID: <87eig2ixez.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

Michael Rubin <mrubin@google.com> writes:
>
> I agree. This would put the kernel in a box a bit. Some of them
> (sys_sync, periodic writeback, free_more_memory) I feel are generic
> enough concepts that with some rewording of the labels they could be
> exposed with no issue. "Balance_dirty_pages" is an example where that
> won't work.

Yes some rewording would be good.

> Are there alternatives to this? Maybe tracepoints that are compiled to be on?
> A CONFIG_WRITEBACK_DEBUG that would expose this file?

The classic way is to put it into debugfs which has a appropiate
disclaimer.

(although I fear we're weaning apps that depend on debugfs too
The growing ftrace user space code seems to all depend on debugfs)

> Having this set of info readily available and collected makes
> debugging a lot easier. But I admit I am not sure the best way to
> expose them.

Maybe we just need a simpler writeback path that is not as complicated
to debug. 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
