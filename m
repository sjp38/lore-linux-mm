Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 540C36B01F1
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 09:48:24 -0400 (EDT)
Message-ID: <4C77C20F.1050405@redhat.com>
Date: Fri, 27 Aug 2010 09:47:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] writeback: remove the internal 5% low bound on dirty_ratio
References: <20100827103603.GB6237@localhost>
In-Reply-To: <20100827103603.GB6237@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Neil Brown <neilb@suse.de>, Con Kolivas <kernel@kolivas.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@fromorbit.com" <david@fromorbit.com>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On 08/27/2010 06:36 AM, Wu Fengguang wrote:
> The dirty_ratio was siliently limited in global_dirty_limits() to>= 5%.
> This is not a user expected behavior. And it's inconsistent with
> calc_period_shift(), which uses the plain vm_dirty_ratio value.
>
> Let's rip the internal bound.
>
> At the same time, fix balance_dirty_pages() to work with the
> dirty_thresh=0 case. This allows applications to proceed when
> dirty+writeback pages are all cleaned.
>
> And ">" fits with the name "exceeded" better than">=" does. Neil
> think it is an aesthetic improvement as well as a functional one :)
>
> CC: Jan Kara<jack@suse.cz>
> CC: Rik van Riel<riel@redhat.com>
> CC: Peter Zijlstra<a.p.zijlstra@chello.nl>
> Proposed-by: Con Kolivas<kernel@kolivas.org>
> Reviewed-by: Neil Brown<neilb@suse.de>
> Reviewed-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
