Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D23379000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 04:21:51 -0400 (EDT)
Received: by wwi36 with SMTP id 36so311170wwi.26
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 01:21:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimzYwa87NJ0F4AEN=9EZs=3-5SBaA@mail.gmail.com>
References: <20110426053150.GA11949@darkstar>
	<BANLkTimzYwa87NJ0F4AEN=9EZs=3-5SBaA@mail.gmail.com>
Date: Tue, 26 Apr 2011 17:21:48 +0900
Message-ID: <BANLkTingHBoK4mtsHkhZxW=p1GcxCjzRsQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] use oom_killer_disabled in page fault oom path
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com

On Tue, Apr 26, 2011 at 5:07 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Tue, Apr 26, 2011 at 2:31 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
>> Currently oom_killer_disabled is only used in __alloc_pages_slowpath,
>> For page fault oom case it is not considered. One use case is
>> virtio balloon driver, when memory pressure is high, virtio ballooning
>> will cause oom killing due to such as page fault oom.
>
> Other mm guys already accepted but sorry I can't understand your point
> since I am not familiar with virtio.
>
> Now oom_killer_disabled is used by only hibernation and hibernation
> freezes processes so page fault shouldn't happen.
>
> Now are you using oom_killer_disabled in virtio?
> Could you elaborate use case ?

Sorry, I lost your [1/2] in my mail box.
I will see it in marc linux-mm

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
