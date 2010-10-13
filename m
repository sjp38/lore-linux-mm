Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E9DDC6B00FF
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 03:01:48 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 13 Oct 2010 09:01:43 +0200
In-Reply-To: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Wed, 13 Oct 2010 12:15:27 +0900")
Message-ID: <87sk0a1sq0.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
>
> What this wants to do: 
>   allocates a contiguous chunk of pages larger than MAX_ORDER.
>   for device drivers (camera? etc..)

I think to really move forward you need a concrete use case
actually implemented in tree.

>   My intention is not for allocating HUGEPAGE(> MAX_ORDER).

I still believe using this for 1GB pages would be one of the more
interesting use cases.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
