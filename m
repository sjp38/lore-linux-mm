Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 336D16B02B8
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 23:46:14 -0400 (EDT)
Message-ID: <4C6DFA78.10800@redhat.com>
Date: Thu, 19 Aug 2010 23:46:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] writeback: remove the internal 5% low bound on dirty_ratio
References: <20100820032506.GA6662@localhost>
In-Reply-To: <20100820032506.GA6662@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>, Jan Kara <jack@suse.cz>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

On 08/19/2010 11:25 PM, Wu Fengguang wrote:
> The dirty_ratio was silently limited to>= 5%. This is not a user
> expected behavior. Let's rip it.
>
> It's not likely the user space will depend on the old behavior.
> So the risk of breaking user space is very low.
>
> CC: Jan Kara<jack@suse.cz>
> CC: Neil Brown<neilb@suse.de>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
