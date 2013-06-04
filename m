Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id C78B26B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 14:09:03 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id x12so517784wgg.10
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 11:09:02 -0700 (PDT)
Date: Tue, 4 Jun 2013 20:08:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v4] Soft limit rework
Message-ID: <20130604180859.GB9321@dhcp22.suse.cz>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
 <CAKTCnz=CMbhhROPV4iC6_XPuu_8J53ZMTdXtY_bevPjG+B-+mw@mail.gmail.com>
 <20130604163828.GA9321@dhcp22.suse.cz>
 <CAKTCnz=MP5iadPJkngJqGMnXSwe9n-xGDEdzuT5Aqoyx0KAYwA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnz=MP5iadPJkngJqGMnXSwe9n-xGDEdzuT5Aqoyx0KAYwA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>

On Tue 04-06-13 23:27:05, Balbir Singh wrote:
> > OK, let me summarize. The primary intention is to get rid of the current
> > soft reclaim infrastructure which basically bypasses the standard
> > reclaim and tight it directly into shrink_zone code. This also means
> > that the soft reclaim doesn't reclaim at priority 0 and that it is
> > active also for the targeted (aka limit) reclaim.
> >
> > Does this help?
> >
> 
> Yes. What are the limitations of no-priority 0 reclaim?

I am not sure I understand the question. What do you mean by
limitations?

The priority-0 scan was always a crude hack. With a lot of pages in on
the LRU it might cause huge big stalls during direct reclaim. There are
workloads which benefited from such an aggressive reclaim - e.g.
streaming IO but that doesn't justify this kind of reclaim.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
