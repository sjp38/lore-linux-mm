Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5D2156B004D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 23:42:34 -0400 (EDT)
Message-ID: <4A5EA1A4.1080502@redhat.com>
Date: Wed, 15 Jul 2009 23:42:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] throttle direct reclaim when too many pages are isolated
 already
References: <20090715223854.7548740a@bree.surriel.com>	<20090715194820.237a4d77.akpm@linux-foundation.org>	<4A5E9A33.3030704@redhat.com>	<20090715202114.789d36f7.akpm@linux-foundation.org>	<4A5E9E4E.5000308@redhat.com> <20090715203854.336de2d5.akpm@linux-foundation.org>
In-Reply-To: <20090715203854.336de2d5.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 15 Jul 2009 23:28:14 -0400 Rik van Riel <riel@redhat.com> wrote:

>> If we are stuck at this point in the page reclaim code,
>> it is because too many other tasks are reclaiming pages.
>>
>> That makes it fairly safe to just return SWAP_CLUSTER_MAX
>> here and hope that __alloc_pages() can get a page.
>>
>> After all, if __alloc_pages() thinks it made progress,
>> but still cannot make the allocation, it will call the
>> pageout code again.
> 
> Which will immediately return because the caller still has
> fatal_signal_pending()?

Other processes are in the middle of freeing pages at
this point, so we should succeed in __alloc_pages()
fairly quickly (and then die and free all our memory).

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
