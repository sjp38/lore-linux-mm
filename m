Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0F3586B01EE
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 09:21:18 -0400 (EDT)
Message-ID: <4BCEFBAB.4070403@redhat.com>
Date: Wed, 21 Apr 2010 09:20:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone pressure
References: <20100322235053.GD9590@csn.ul.ie> <4BA940E7.2030308@redhat.com> <20100324145028.GD2024@csn.ul.ie> <4BCC4B0C.8000602@linux.vnet.ibm.com> <20100419214412.GB5336@cmpxchg.org> <4BCD55DA.2020000@linux.vnet.ibm.com> <20100420153202.GC5336@cmpxchg.org> <4BCDE2F0.3010009@redhat.com> <4BCE7DD1.70900@linux.vnet.ibm.com>
In-Reply-To: <4BCE7DD1.70900@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>
List-ID: <linux-mm.kvack.org>

On 04/21/2010 12:23 AM, Christian Ehrhardt wrote:

> IMHO it is fine to prevent that nightly backup job from not being
> finished when the user arrives at morning because we didn't give him
> some more cache

How on earth would a backup job benefit from cache?

It only accesses each bit of data once, so caching the
to-be-backed-up data is a waste of memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
