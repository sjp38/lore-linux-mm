Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 6DD536B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 15:24:46 -0500 (EST)
Received: by vbip1 with SMTP id p1so1681288vbi.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 12:24:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120201095556.812db19c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120201095556.812db19c.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 1 Feb 2012 12:24:25 -0800
Message-ID: <CAHH2K0bPdqzpuWv82uyvEu4d+cDqJOYoHbw=GeP5OZk4-3gCUg@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] memcg topics.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Wu Fengguang <fengguang.wu@intel.com>

On Tue, Jan 31, 2012 at 4:55 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 4. dirty ratio
> =A0 In the last year, patches were posted but not merged. I'd like to hea=
r
> =A0 works on this area.

I would like to attend to discuss this topic.  I have not had much time to =
work
on this recently, but should be able to focus more on this soon.  The
IO less writeback changes require some redesign and may allow for a
simpler implementation of mem_cgroup_balance_dirty_pages().
Maintaining a per container dirty page counts, ratios, and limits is
fairly easy, but integration with writeback is the challenge.  My big
questions are for writeback people:
1. how to compute per-container pause based on bdi bandwidth, cgroup
dirty page usage.
2. how to ensure that writeback will engage even if system and bdi are
below respective background dirty ratios, yet a memcg is above its bg
dirty limit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
