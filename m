Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BE2076B005D
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:23:18 -0400 (EDT)
Message-ID: <4A4B9BA1.6040109@redhat.com>
Date: Wed, 01 Jul 2009 13:23:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] Show kernel stack usage to /proc/meminfo and OOM log
References: <20090701103622.85CD.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0906301011210.6124@gentwo.org> <20090701082531.85C2.A69D9226@jp.fujitsu.com> <10604.1246459458@redhat.com> <alpine.DEB.1.10.0907011315540.9522@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0907011315540.9522@gentwo.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 1 Jul 2009, David Howells wrote:
> 
>> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>>> +	int pages = THREAD_SIZE / PAGE_SIZE;
>> Bad assumption.  On FRV, for example, THREAD_SIZE is 8K and PAGE_SIZE is 16K.
> 
> Guess that means we need arch specific accounting for this counter.

Or we count the number of stacks internally and only
convert to pages whenever we display the value.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
