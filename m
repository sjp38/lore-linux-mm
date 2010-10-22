Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9E78D6B0085
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 08:00:57 -0400 (EDT)
Message-ID: <4CC17CF1.4000109@redhat.com>
Date: Fri, 22 Oct 2010 08:00:49 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Avoid possible deadlock caused by too_many_isolated()
References: <20101022045509.GA16804@localhost>
In-Reply-To: <20101022045509.GA16804@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On 10/22/2010 12:55 AM, Wu Fengguang wrote:

> Now !GFP_IOFS reclaims won't be waiting for GFP_IOFS reclaims to
> progress. They will be blocked only when there are too many concurrent
> !GFP_IOFS reclaims, however that's very unlikely because the IO-less
> direct reclaims is able to progress much more faster, and they won't
> deadlock each other. The threshold is raised high enough for them, so
> that there can be sufficient parallel progress of !GFP_IOFS reclaims.
>
> CC: Torsten Kaiser<just.for.lkml@googlemail.com>
> CC: Minchan Kim<minchan.kim@gmail.com>
> Tested-by: NeilBrown<neilb@suse.de>
> Acked-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
