Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1F46B02C3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 02:14:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g46so35135514wrd.3
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 23:14:59 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id s17si3261937wra.76.2017.06.28.23.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 23:14:58 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id b184so2830596wme.1
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 23:14:57 -0700 (PDT)
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
References: <bug-196157-27@https.bugzilla.kernel.org/>
 <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
 <20170623071324.GD5308@dhcp22.suse.cz>
 <3541d6c3-6c41-8210-ee94-fef313ecd83d@gmail.com>
 <20170623113837.GM5308@dhcp22.suse.cz>
 <a373c35d-7d83-973c-126e-a08c411115cb@gmail.com>
 <20170626054623.GC31972@dhcp22.suse.cz>
 <7b78db49-e0d8-9ace-bada-a48c9392a8ca@gmail.com>
 <20170626091254.GG11534@dhcp22.suse.cz>
From: Alkis Georgopoulos <alkisg@gmail.com>
Message-ID: <5eff5b8f-51ab-9749-0da5-88c270f0df92@gmail.com>
Date: Thu, 29 Jun 2017 09:14:55 +0300
MIME-Version: 1.0
In-Reply-To: <20170626091254.GG11534@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

I've been working on a system with highmem_is_dirtyable=1 for a couple
of hours.

While the disk benchmark showed no performance hit on intense disk
activity, there are other serious problems that make this workaround
unusable.

I.e. when there's intense disk activity, the mouse cursor moves with
extreme lag, like 1-2 fps. Switching with alt+tab from e.g. thunderbird
to pidgin needs 10 seconds. kswapd hits 100% cpu usage. Etc etc, the
system becomes unusable until the disk activity settles down.
I was testing via SSH so I hadn't noticed the extreme lag.

All those symptoms go away when resetting highmem_is_dirtyable=0.

So currently 32bit installations with 16 GB RAM have no option but to
remove the extra RAM...


About ab8fabd46f81 ("mm: exclude reserved pages from dirtyable memory"),
would it make sense for me to compile a kernel and test if everything
works fine without it? I.e. if we see that this caused all those
regressions, would it be revisited?

And an unrelated idea, is there any way to tell linux to use a limited
amount of RAM for page cache, e.g. only 1 GB?

Kind regards,
Alkis Georgopoulos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
