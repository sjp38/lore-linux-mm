Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6E86B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 07:50:23 -0400 (EDT)
Received: by iwg8 with SMTP id 8so6637830iwg.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 04:50:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110523112558.GC11439@tiehlicka.suse.cz>
References: <BANLkTinLvqa0DiayLOwvxE9zBmqb4Y7Rww@mail.gmail.com>
	<20110523112558.GC11439@tiehlicka.suse.cz>
Date: Mon, 23 May 2011 19:50:21 +0800
Message-ID: <BANLkTi=2SwKFfwBxrQr3xLYSUzoGOy6oKA@mail.gmail.com>
Subject: Re: [Patch] mm: remove noswapaccount kernel parameter
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, May 23, 2011 at 7:25 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 23-05-11 19:08:08, Am??rico Wang wrote:
>> noswapaccount is deprecated by swapaccount=0, and it is scheduled
>> to be removed in 2.6.40.
>
> Similar patch is already in the Andrew's tree

Ah, my google search failed to find it. :-/

> (memsw-remove-noswapaccount-kernel-parameter.patch). Andrew, are you
> going to push it?
> Btw. the patch is missing documentation part which is present here.
>

Hmm, maybe I should send a delta patch... Andrew?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
