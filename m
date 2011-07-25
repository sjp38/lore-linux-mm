Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B595D6B00EE
	for <linux-mm@kvack.org>; Sun, 24 Jul 2011 23:47:28 -0400 (EDT)
Received: by qyk4 with SMTP id 4so2719822qyk.14
        for <linux-mm@kvack.org>; Sun, 24 Jul 2011 20:47:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87vcurrrad.fsf@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com>
	<20101208170504.1750.A69D9226@jp.fujitsu.com>
	<AANLkTikG1EAMm8yPvBVUXjFz1Bu9m+vfwH3TRPDzS9mq@mail.gmail.com>
	<87oc8wa063.fsf@gmail.com>
	<AANLkTin642NFLMubtCQhSVUNLzfdk5ajz-RWe2zT+Lw6@mail.gmail.com>
	<20101213153105.GA2344@barrios-desktop>
	<87lj3t30a9.fsf@gmail.com>
	<AANLkTikT_HNvuBR0J-2COgB54gquj2FineOjkzU+mt6_@mail.gmail.com>
	<87vcurrrad.fsf@gmail.com>
Date: Mon, 25 Jul 2011 12:47:25 +0900
Message-ID: <CAEwNFnBnsi6WePqqo_8ES4Zxa2JZ43_7PHcO1ABh5+hwopSngA@mail.gmail.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>

Hi Ben,

On Mon, Jul 25, 2011 at 12:08 PM, Ben Gamari <bgamari.foss@gmail.com> wrote:
> On Tue, 14 Dec 2010 11:36:12 +0900, Minchan Kim <minchan.kim@gmail.com> wrote:
>> Hi Ben,
>>
>> [snipped]
>
> What exactly happened to this set? It seems it dropped off my radar and
> otherwise never was merged. Was it not tested enough, the benefit not
> great enough, or did it simply slip through the cracks?

It is already merged.
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=315601809d124d046abd6c3ffa346d0dbd7aa29d

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
