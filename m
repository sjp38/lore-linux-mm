Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0E4136B012F
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 23:15:15 -0400 (EDT)
Message-ID: <4E000CB5.3050201@redhat.com>
Date: Tue, 21 Jun 2011 11:15:01 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <20110620165035.GE20843@redhat.com> <4DFF7CDD.308@redhat.com> <20110620194321.GI20843@redhat.com>
In-Reply-To: <20110620194321.GI20843@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 03:43, Andrea Arcangeli a??e??:
> On Tue, Jun 21, 2011 at 01:01:17AM +0800, Cong Wang wrote:
>> Without this patch, THP is still initialized (although khugepaged is not started),
>> that is what I don't want to see when I pass "transparent_hugepage=never",
>> because "never" for me means THP is totally unseen, even not initialized.
>
> The ram saving by not registering in sysfs is not worth the loss of
> generic functionality. You can try to make the hash and slab
> khugepaged allocations more dynamic if you want to microoptimize for
> RAM usage, that I wouldn't be against if you find a way to do it
> simply and without much complexity (and .text) added. But likely there
> are other places to optimize that may introduce less tricks and would
> give you a bigger saving than ~8kbytes, it's up to you.

But the THP functionality is not going to be used.

Yeah, sounds reasonable, I will try to check if I can make it.

Thanks for pointing this out!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
