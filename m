Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1CF6B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 02:34:19 -0400 (EDT)
Received: by iyb14 with SMTP id 14so4531160iyb.14
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 23:34:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b24894c23d0bb06f849822cb30726b532ea3a4c5.1310732789.git.mhocko@suse.cz>
References: <cover.1310732789.git.mhocko@suse.cz>
	<b24894c23d0bb06f849822cb30726b532ea3a4c5.1310732789.git.mhocko@suse.cz>
Date: Wed, 20 Jul 2011 12:04:17 +0530
Message-ID: <CAKTCnzkiRW3aLwnCYyb9XPfTZWipqcA5Jd7d27rZpecqn3wFuQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] memcg: change memcg_oom_mutex to spinlock
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu, Jul 14, 2011 at 8:59 PM, Michal Hocko <mhocko@suse.cz> wrote:
> memcg_oom_mutex is used to protect memcg OOM path and eventfd interface
> for oom_control. None of the critical sections which it protects sleep
> (eventfd_signal works from atomic context and the rest are simple linked
> list resp. oom_lock atomic operations).
> Mutex is also too heavy weight for those code paths because it triggers
> a lot of scheduling. It also makes makes convoying effects more visible
> when we have a big number of oom killing because we take the lock
> mutliple times during mem_cgroup_handle_oom so we have multiple places
> where many processes can sleep.
>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Quick question: How long do we expect this lock to be taken? What
happens under oom? Any tests? Numbers?

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
