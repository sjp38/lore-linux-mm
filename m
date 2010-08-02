Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 019486B02E4
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 00:38:37 -0400 (EDT)
Received: by gwj16 with SMTP id 16so1509870gwj.14
        for <linux-mm@kvack.org>; Sun, 01 Aug 2010 21:38:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100802131016.4F7D.A69D9226@jp.fujitsu.com>
References: <20100801180751.4B0E.A69D9226@jp.fujitsu.com>
	<20100801134117.GA2034@barrios-desktop>
	<20100802131016.4F7D.A69D9226@jp.fujitsu.com>
Date: Mon, 2 Aug 2010 13:38:29 +0900
Message-ID: <AANLkTinqDTy1S+DvKaCCQQ7bA7E-XZ-3S0Xx6c64EvGb@mail.gmail.com>
Subject: Re: [PATCH] vmscan: synchronous lumpy reclaim don't call
	congestion_wait()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 2, 2010 at 1:13 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> Hi KOSAKI,
>>
>> On Sun, Aug 01, 2010 at 06:12:47PM +0900, KOSAKI Motohiro wrote:
>> > rebased onto Wu's patch
>> >
>> > ----------------------------------------------
>> > From 35772ad03e202c1c9a2252de3a9d3715e30d180f Mon Sep 17 00:00:00 2001
>> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > Date: Sun, 1 Aug 2010 17:23:41 +0900
>> > Subject: [PATCH] vmscan: synchronous lumpy reclaim don't call congesti=
on_wait()
>> >
>> > congestion_wait() mean "waiting for number of requests in IO queue is
>> > under congestion threshold".
>> > That said, if the system have plenty dirty pages, flusher thread push
>> > new request to IO queue conteniously. So, IO queue are not cleared
>> > congestion status for a long time. thus, congestion_wait(HZ/10) is
>> > almostly equivalent schedule_timeout(HZ/10).
>> Just a nitpick.
>> Why is it a problem?
>> HZ/10 is upper bound we intended. =A0If is is rahter high, we can low it=
.
>> But totally I agree on this patch. It would be better to remove it
>> than lowing.
>
> because all of _unnecessary_ sleep is evil. the problem is, congestion_wa=
it()
> mean "wait until queue congestion will be cleared, iow, wait all of IO".
> but we want to wait until _my_ IO finished.
>
> So, if flusher thread conteniously push new IO into the queue, that makes
> big difference.
>

Agree. Please include this explanation in description to make it kind
if you resent this patch.
Thanks


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
