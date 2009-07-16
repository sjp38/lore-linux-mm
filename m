Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BD7A36B004D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 23:48:03 -0400 (EDT)
Message-ID: <4A5EA2EF.3050501@redhat.com>
Date: Wed, 15 Jul 2009 23:47:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] throttle direct reclaim when too many pages are isolated
 already
References: <20090715223854.7548740a@bree.surriel.com>	<20090716121956.fc50949f.kamezawa.hiroyu@jp.fujitsu.com>	<4A5E9F3D.1040600@redhat.com> <20090716124255.3d601efb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090716124255.3d601efb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:

>> Am I overlooking something?
>>
> Reclaim from cgorup doesn't come from memory shortage but from
> "it hits limit". Then, it doen't necessary to reclaim pages from
> this zone. fallback to other zone is always ok.
> This will trigger unnecessary wait, I think.

Fair enough.

I'll also change the patch so tasks with a fatal signal
pending will go through congestion_wait at least once,
to give other tasks a chance to free up memory.

That should address everybody's concerns.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
