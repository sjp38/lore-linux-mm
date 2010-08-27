Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6C5F96B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 22:02:54 -0400 (EDT)
Received: by iwn33 with SMTP id 33so2791445iwn.14
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 19:02:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100827015041.GF7353@localhost>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
	<20100826172038.GA6873@barrios-desktop>
	<20100827012147.GC7353@localhost>
	<AANLkTimLhZcP=eqB9TFfO_rgb-dhXUJh8iNTXuceuCq0@mail.gmail.com>
	<20100827015041.GF7353@localhost>
Date: Fri, 27 Aug 2010 11:02:52 +0900
Message-ID: <AANLkTin0PZu=ceoeyYa6qSv_piHL1yrfyEgTw35=gnex@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] Do not wait the full timeout on congestion_wait
 when there is no congestion
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 10:50 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> On Fri, Aug 27, 2010 at 09:41:48AM +0800, Minchan Kim wrote:
>> Hi, Wu.
>>
>> On Fri, Aug 27, 2010 at 10:21 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
>> > Minchan,
>> >
>> > It's much cleaner to keep the unchanged congestion_wait() and add a
>> > congestion_wait_check() for converting problematic wait sites. The
>> > too_many_isolated() wait is merely a protective mechanism, I won't
>> > bother to improve it at the cost of more code.
>>
>> You means following as?
>
> No, I mean do not change the too_many_isolated() related code at all :)
> And to use congestion_wait_check() in other places that we can prove
> there is a problem that can be rightly fixed by changing to
> congestion_wait_check().

I always suffer from understanding your comment.
Apparently, my eyes have a problem. ;(

This patch is dependent of Mel's series.
With changing congestion_wait with just return when no congestion, it
would have CPU hogging in too_many_isolated. I think it would apply in
Li's congestion_wait_check, too.
If no change is current congestion_wait, we doesn't need this patch.

Still, maybe I can't understand your comment. Sorry.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
