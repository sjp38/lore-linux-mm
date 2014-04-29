Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 800376B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 06:50:23 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id e16so10651lan.41
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 03:50:21 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [2a02:6b8:0:801::10])
        by mx.google.com with ESMTPS id sz4si10623917lbb.183.2014.04.29.03.50.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Apr 2014 03:50:21 -0700 (PDT)
From: Roman Gushchin <klamm@yandex-team.ru>
In-Reply-To: <xr938uqoa8ei.fsf@gthelen.mtv.corp.google.com>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz> <10861398700008@webcorp2f.yandex-team.ru> <xr938uqoa8ei.fsf@gthelen.mtv.corp.google.com>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
MIME-Version: 1.0
Message-Id: <7441398768618@webcorp2f.yandex-team.ru>
Date: Tue, 29 Apr 2014 14:50:18 +0400
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=koi8-r
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

29.04.2014, 11:42, "Greg Thelen" <gthelen@google.com>:
> On Mon, Apr 28 2014, Roman Gushchin <klamm@yandex-team.ru> wrote:
>
>> ?28.04.2014, 16:27, "Michal Hocko" <mhocko@suse.cz>:
>>> ?The series is based on top of the current mmotm tree. Once the series
>>> ?gets accepted I will post a patch which will mark the soft limit as
>>> ?deprecated with a note that it will be eventually dropped. Let me know
>>> ?if you would prefer to have such a patch a part of the series.
>>>
>>> ?Thoughts?
>> ?Looks good to me.
>>
>> ?The only question is: are there any ideas how the hierarchy support
>> ?will be used in this case in practice?
>> ?Will someone set low limit for non-leaf cgroups? Why?
>>
>> ?Thanks,
>> ?Roman
>
> I imagine that a hosting service may want to give X MB to a top level
> memcg (/a) with sub-jobs (/a/b, /a/c) which may(not) have their own
> low-limits.
>
> Examples:
>
> case_1) only set low limit on /a. ?/a/b and /a/c may overcommit /a's
> ????????memory (b.limit_in_bytes + c.limit_in_bytes > a.limit_in_bytes).
>
> case_2) low limits on all memcg. ?But not overcommitting low_limits
> ????????(b.low_limit_in_in_bytes + c.low_limit_in_in_bytes <=
> ????????a.low_limit_in_in_bytes).

Thanks!

With use_hierarchy turned on it looks perfectly usable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
