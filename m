Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 98C0A90010C
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 04:07:36 -0400 (EDT)
Received: by vxk20 with SMTP id 20so461598vxk.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 01:07:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426053150.GA11949@darkstar>
References: <20110426053150.GA11949@darkstar>
Date: Tue, 26 Apr 2011 17:07:34 +0900
Message-ID: <BANLkTimzYwa87NJ0F4AEN=9EZs=3-5SBaA@mail.gmail.com>
Subject: Re: [PATCH 2/2] use oom_killer_disabled in page fault oom path
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com

On Tue, Apr 26, 2011 at 2:31 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
> Currently oom_killer_disabled is only used in __alloc_pages_slowpath,
> For page fault oom case it is not considered. One use case is
> virtio balloon driver, when memory pressure is high, virtio ballooning
> will cause oom killing due to such as page fault oom.

Other mm guys already accepted but sorry I can't understand your point
since I am not familiar with virtio.

Now oom_killer_disabled is used by only hibernation and hibernation
freezes processes so page fault shouldn't happen.

Now are you using oom_killer_disabled in virtio?
Could you elaborate use case ?

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
