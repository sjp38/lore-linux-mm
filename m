Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 79B986B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 03:46:35 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so574325yxh.26
        for <linux-mm@kvack.org>; Wed, 29 Apr 2009 00:47:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090428233455.614dcf3a.akpm@linux-foundation.org>
References: <20090428090916.GC17038@localhost> <20090428120818.GH22104@mit.edu>
	 <20090429130430.4B11.A69D9226@jp.fujitsu.com>
	 <20090428233455.614dcf3a.akpm@linux-foundation.org>
Date: Wed, 29 Apr 2009 16:47:18 +0900
Message-ID: <2f11576a0904290047i1bd8fc6cu7d70a3ac32bf7b5a@mail.gmail.com>
Subject: Re: Swappiness vs. mmap() and interactive response
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Theodore Tso <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

>> Mapped page decrease rapidly: not happend (I guess, these page stay in
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 active list on my system)
>> page fault large latency: =A0 =A0 happend (latencytop display >200ms)
>
> hm. =A0The last two observations appear to be inconsistent.

it mean existing process don't slow down. but new process creation is very =
slow.


> Elladan, have you checked to see whether the Mapped: number in
> /proc/meminfo is decreasing?
>
>>
>> Then, I don't doubt vm replacement logic now.
>> but I need more investigate.
>> I plan to try following thing today and tommorow.
>>
>> =A0- XFS
>> =A0- LVM
>> =A0- another io scheduler (thanks Ted, good view point)
>> =A0- Rik's new patch
>
> It's not clear that we know what's happening yet, is it? =A0It's such a
> gross problem that you'd think that even our testing would have found
> it by now :(

Yes, unclear. but various testing can drill down the reason, I think.


> Elladan, do you know if earlier kernels (2.6.26 or thereabouts) had
> this severe a problem?
>
> (notes that we _still_ haven't unbusted prev_priority)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
