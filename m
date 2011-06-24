Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B3091900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 07:46:33 -0400 (EDT)
Received: by bwd14 with SMTP id 14so152808bwd.14
        for <linux-mm@kvack.org>; Fri, 24 Jun 2011 04:46:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110624075742.GA10455@tiehlicka.suse.cz>
References: <20110622120635.GB14343@tiehlicka.suse.cz>
	<20110622121516.GA28359@infradead.org>
	<20110622123204.GC14343@tiehlicka.suse.cz>
	<20110623150842.d13492cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623074133.GA31593@tiehlicka.suse.cz>
	<20110623170811.16f4435f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623090204.GE31593@tiehlicka.suse.cz>
	<20110623190157.1bc8cbb9.kamezawa.hiroyu@jp.fujitsu.com>
	<20110624075742.GA10455@tiehlicka.suse.cz>
Date: Fri, 24 Jun 2011 20:46:29 +0900
Message-ID: <BANLkTin7TbK1dNjPG6jz_FaJy-QgOjDJaA@mail.gmail.com>
Subject: Re: [PATCH] mm: preallocate page before lock_page at filemap COW.
 (WasRe: [PATCH V2] mm: Do not keep page locked during page fault while
 charging it for memcg
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Lutz Vieweg <lvml@5t9.de>

2011/6/24 Michal Hocko <mhocko@suse.cz>:
> Sorry, forgot to send my
> Reviewed-by: Michal Hocko <mhocko@suse>
>

Thanks.

> I still have concerns about this way to handle the issue. See the follow
> up discussion in other thread (https://lkml.org/lkml/2011/6/23/135).
>
> Anyway I think that we do not have many other options to handle this.
> Either we unlock, charge, lock&restes or we preallocate, fault in
>
I agree.

> Or am I missing some other ways how to do it? What do others think about
> these approaches?
>

Yes, I'd like to hear other mm specialists' suggestion. and I'll think
other way, again.
Anyway, memory reclaim with holding a lock_page() can cause big latency
or starvation especially when memcg is used. It's better to avoid it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
