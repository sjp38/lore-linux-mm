Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 94B376B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 22:31:02 -0400 (EDT)
Message-ID: <4C7C6959.3030801@redhat.com>
Date: Mon, 30 Aug 2010 22:30:49 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap
 system
References: <AANLkTi==mQh31PzuNa1efH2WM1s-VPKyZX0f5iwb54PD@mail.gmail.com>	<AANLkTinqm0o=AfmgFy+SpZ1mrdekRnjeXvs_7=OcLii8@mail.gmail.com>	<20100831095140.87C7.A69D9226@jp.fujitsu.com> <AANLkTin4-NomOoNFYCKgi7oE+MCUiC0o0ftAkOwLKez_@mail.gmail.com>
In-Reply-To: <AANLkTin4-NomOoNFYCKgi7oE+MCUiC0o0ftAkOwLKez_@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On 08/30/2010 09:23 PM, Minchan Kim wrote:

> Ying's one and mine both has a same effect.
> Only difference happens swap is full. My version maintains old
> behavior but Ying's one changes the behavior. I admit swap full is
> rare event but I hoped not changed old behavior if we doesn't find any
> problem.
> If kswapd does aging when swap full happens, is it a problem?

It may be a good thing, since swap will often be freed again
(when something is swapped in, or exits).

Having some more anonymous pages sit on the inactive list
gives them a chance to get used again, potentially giving
us a better chance of preserving the working set when swap
is full or near full a lot of the time.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
