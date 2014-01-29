Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9026B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 13:23:06 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id t10so1084047eei.35
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 10:23:05 -0800 (PST)
Received: from mail-ea0-x231.google.com (mail-ea0-x231.google.com [2a00:1450:4013:c01::231])
        by mx.google.com with ESMTPS id t5si5954535eeo.148.2014.01.29.10.23.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 10:23:04 -0800 (PST)
Received: by mail-ea0-f177.google.com with SMTP id n15so1114441ead.8
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 10:23:03 -0800 (PST)
Date: Wed, 29 Jan 2014 19:22:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/4] memcg: Low-limit reclaim
Message-ID: <20140129182259.GA6711@dhcp22.suse.cz>
References: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
 <52E24956.3000007@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52E24956.3000007@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Fri 24-01-14 15:07:02, Roman Gushchin wrote:
> Hi, Michal!

Hi,

> As you can remember, I've proposed to introduce low limits about a year ago.
> 
> We had a small discussion at that time: http://marc.info/?t=136195226600004 .

yes I remember that discussion and vaguely remember the proposed
approach. I really wanted to prevent from introduction of a new knob but
things evolved differently than I planned since then and it turned out
that the knew knob is unavoidable. That's why I came with this approach
which is quite different from yours AFAIR.
 
> Since that time we intensively use low limits in our production
> (on thousands of machines). So, I'm very interested to merge this
> functionality into upstream.

Have you tried to use this implementation? Would this work as well?
My very vague recollection of your patch is that it didn't cover both
global and target reclaims and it didn't fit into the reclaim very
naturally it used its own scaling method. I will have to refresh my
memory though.

> In my experience, low limits also require some changes in memcg page accounting
> policy. For instance, an application in protected cgroup should have a guarantee
> that it's filecache belongs to it's cgroup and is protected by low limit
> therefore. If the filecache was created by another application in other cgroup,
> it can be not so. I've solved this problem by implementing optional page
> reaccouting on pagefaults and read/writes.

Memory sharing is a separate issue and we should discuss that
separately. 

> I can prepare my current version of patchset, if someone is interested.

Sure, having something to compare with is always valuable.

> Regards,
> Roman
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
