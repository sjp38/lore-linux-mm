Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 35E466B01B7
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:11:39 -0400 (EDT)
Received: by iwn39 with SMTP id 39so1762411iwn.14
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 23:11:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100603135106.7247.A69D9226@jp.fujitsu.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com>
Date: Thu, 3 Jun 2010 15:11:41 +0900
Message-ID: <AANLkTikCp17CnCzHVPtHIP7BQriD9Oddsm5T0W0aricJ@mail.gmail.com>
Subject: Re: [mmotm 0521][PATCH 0/12] various OOM fixes for 2.6.35
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 3, 2010 at 2:48 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
> This patch series is collection of various OOM bugfixes. I think
> all of patches can send to 2.6.35.
> Recently, David Rientjes and Luis Claudio R. Goncalves posted other
> various imporovement. I'll collect such 2.6.36 items and I plan to
> push -mm at next week.

Recently, there are many confusion due to patches related OOM.
You are cleaning up it and looks better than old for review.
Thanks for your great effort.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
