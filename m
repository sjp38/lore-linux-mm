Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 1B6106B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 13:57:07 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id ia10so423853vcb.14
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 10:57:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130604163828.GA9321@dhcp22.suse.cz>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
	<CAKTCnz=CMbhhROPV4iC6_XPuu_8J53ZMTdXtY_bevPjG+B-+mw@mail.gmail.com>
	<20130604163828.GA9321@dhcp22.suse.cz>
Date: Tue, 4 Jun 2013 23:27:05 +0530
Message-ID: <CAKTCnz=MP5iadPJkngJqGMnXSwe9n-xGDEdzuT5Aqoyx0KAYwA@mail.gmail.com>
Subject: Re: [patch v4] Soft limit rework
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>

> OK, let me summarize. The primary intention is to get rid of the current
> soft reclaim infrastructure which basically bypasses the standard
> reclaim and tight it directly into shrink_zone code. This also means
> that the soft reclaim doesn't reclaim at priority 0 and that it is
> active also for the targeted (aka limit) reclaim.
>
> Does this help?
>

Yes. What are the limitations of no-priority 0 reclaim? I'll also look
at the patches

Thanks,
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
