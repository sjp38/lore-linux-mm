Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 917066B0055
	for <linux-mm@kvack.org>; Tue, 19 May 2009 11:54:36 -0400 (EDT)
Received: by gxk20 with SMTP id 20so7937392gxk.14
        for <linux-mm@kvack.org>; Tue, 19 May 2009 08:55:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A12B30D.9040002@redhat.com>
References: <20090519161756.4EE4.A69D9226@jp.fujitsu.com>
	 <20090519074925.GA690@localhost>
	 <20090519170208.742C.A69D9226@jp.fujitsu.com>
	 <20090519085354.GB2121@localhost> <4A12B30D.9040002@redhat.com>
Date: Wed, 20 May 2009 00:55:22 +0900
Message-ID: <2f11576a0905190855j658a608en36f52e8eecfdf6fd@mail.gmail.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class
	citizen
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

>> Another (amazing) finding of the test is, only around 1/10 mapped pages
>> are actively referenced in the absence of user activities.
>>
>> Shall we protect the remaining 9/10 inactive ones? This is a question ;-)
>
> I believe we already do, due to the active list not being
> scanned if none of the streaming IO pages get promoted to
> the active list.

his workload is,

lseek(0)
read(110 * 4096)
lseek(100 * 4096)
read(110 * 4096)
lseek(200 * 4096)
read(110 * 4096)
....

IOW, 90% pages move into inactive list, 10% (overlapped readed) pages
move into active list.
he think it is file server simulation.

I don't know it is good simulation or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
