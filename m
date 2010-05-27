Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E7CAC600385
	for <linux-mm@kvack.org>; Thu, 27 May 2010 10:10:44 -0400 (EDT)
Message-ID: <4BFE7CFC.4060706@redhat.com>
Date: Thu, 27 May 2010 10:09:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] extend KSM refcounts to the anon_vma root
References: <20100526153819.6e5cec0d@annuminas.surriel.com> <20100526154124.04607d04@annuminas.surriel.com> <20100527140212.GE2112@barrios-desktop>
In-Reply-To: <20100527140212.GE2112@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On 05/27/2010 10:02 AM, Minchan Kim wrote:

> Hmm, I can understand this point.
> Now, rmap code always depeneds on root anon_vma's lock.
> I think it doesn't depends on KSM and MIGRATION.
>
> If we don't use KSM and MIGRATION and it is compiled out,
> Can root's anon_vma disappear during rmap walking?
> who prevent it?
>
> What am I missing?

unlink_anon_vmas walks the list in the order from newest
to oldest, ie. the root always gets unlinked (and potentially
freed) last.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
