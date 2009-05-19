Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DFB8E6B005A
	for <linux-mm@kvack.org>; Tue, 19 May 2009 09:24:25 -0400 (EDT)
Message-ID: <4A12B30D.9040002@redhat.com>
Date: Tue, 19 May 2009 09:24:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first	class
 citizen
References: <20090519161756.4EE4.A69D9226@jp.fujitsu.com> <20090519074925.GA690@localhost> <20090519170208.742C.A69D9226@jp.fujitsu.com> <20090519085354.GB2121@localhost>
In-Reply-To: <20090519085354.GB2121@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:

> Another (amazing) finding of the test is, only around 1/10 mapped pages
> are actively referenced in the absence of user activities.
> 
> Shall we protect the remaining 9/10 inactive ones? This is a question ;-)

I believe we already do, due to the active list not being
scanned if none of the streaming IO pages get promoted to
the active list.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
