Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 22A2B6B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 06:12:08 -0400 (EDT)
Received: by gxk3 with SMTP id 3so78944gxk.14
        for <linux-mm@kvack.org>; Thu, 09 Jul 2009 03:27:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090709161712.23B0.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.1.10.0907071252060.5124@gentwo.org>
	 <20090709144938.23A8.A69D9226@jp.fujitsu.com>
	 <20090709161712.23B0.A69D9226@jp.fujitsu.com>
Date: Thu, 9 Jul 2009 19:27:52 +0900
Message-ID: <28c262360907090327w63b0cdfdn5bc2ad628239e53b@mail.gmail.com>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 9, 2009 at 4:20 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > On Mon, 6 Jul 2009, Minchan Kim wrote:
>> >
>> > > Anyway, I think it's not a big cost in normal system.
>> > > So If you want to add new accounting, I don't have any objection. :)
>> >
>> > Lets keep the counters to a mininum. If we can calculate the values from
>> > something else then there is no justification for a new counter.
>> >
>> > A new counter increases the size of the per cpu structures that exist for
>> > each zone and each cpu. 1 byte gets multiplies by the number of cpus and
>> > that gets multiplied by the number of zones.
>>
>> OK. I'll implement this idea.
>
> Grr, sorry I cancel this opinion. Shem pages can't be calculated
> by minchan's formula.
>
> if those page are mlocked, the page move to unevictable lru. then
> this calculation don't account mlocked page. However mlocked tmpfs pages
> also make OOM issue.

Absolutely. You're right.
But In my opinion,  mlocked shmem pages are important ?
Now we care only number of unevictable pages but don't care what kinds
of pages there are in unevictable list.

What we need is to decode OOM more easily.
I think what kinds of pages there area unevictable lur list is not important.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
