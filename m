Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DF8B16B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 03:55:42 -0500 (EST)
Date: Thu, 24 Nov 2011 09:55:33 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 7/8] mm: memcg: modify PageCgroupAcctLRU non-atomically
Message-ID: <20111124085532.GB6843@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
 <1322062951-1756-8-git-send-email-hannes@cmpxchg.org>
 <20111124090915.2f6e2e2c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111124090915.2f6e2e2c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 24, 2011 at 09:09:15AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 23 Nov 2011 16:42:30 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > From: Johannes Weiner <jweiner@redhat.com>
> > 
> > This bit is protected by zone->lru_lock, there is no need for locked
> > operations when setting and clearing it.
> > 
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> 
> This atomic ops are for avoiding race with other ops as lock_page_cgroup().
> Or other Set/ClearPageCgroup....
> 
> Do I misunderstand atomic ops v.s. non-atomic ops race ?

Nope, you are spot-on.  I'm the cretin. ;-) See my reply to Hugh's
email.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
